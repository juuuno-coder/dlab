/**
 * ComfyUI WebSocket/REST 클라이언트
 * ComfyUI의 API를 통해 워크플로를 큐잉하고 결과를 가져옵니다
 */
import fs from "fs";
import path from "path";
import WebSocket from "ws";

const WORKFLOWS_DIR = path.join(__dirname, "..", "workflows");

export interface ComfyResult {
  images: Array<{ base64: string }>;
  execution_time: number;
}

export class ComfyUIClient {
  private baseUrl: string;
  private wsUrl: string;
  private clientId: string;

  constructor() {
    const host = process.env.COMFYUI_HOST || "127.0.0.1";
    const port = process.env.COMFYUI_PORT || "8188";
    this.baseUrl = `http://${host}:${port}`;
    this.wsUrl = `ws://${host}:${port}/ws`;
    this.clientId = `mcp_${Date.now()}`;
  }

  // ── 사전 정의 워크플로 빌더 ──

  buildTxt2Img(opts: {
    prompt: string;
    negative_prompt?: string;
    model?: string;
    width: number;
    height: number;
    steps: number;
    cfg_scale: number;
    seed?: number;
  }): any {
    // 기본 워크플로 JSON 로드
    const template = this.loadWorkflow("txt2img.json");

    // 노드별 값 주입 (ComfyUI API 포맷)
    // TODO: 실제 워크플로 노드 ID에 맞게 조정
    const workflow = JSON.parse(JSON.stringify(template));

    // KSampler 노드
    this.setNodeValue(workflow, "sampler", "seed", opts.seed ?? Math.floor(Math.random() * 2**32));
    this.setNodeValue(workflow, "sampler", "steps", opts.steps);
    this.setNodeValue(workflow, "sampler", "cfg", opts.cfg_scale);

    // CLIP Text Encode (Positive)
    this.setNodeValue(workflow, "positive_prompt", "text", opts.prompt);

    // CLIP Text Encode (Negative)
    this.setNodeValue(workflow, "negative_prompt", "text",
      opts.negative_prompt || "blurry, low quality, text, watermark");

    // Empty Latent Image
    this.setNodeValue(workflow, "latent_image", "width", opts.width);
    this.setNodeValue(workflow, "latent_image", "height", opts.height);

    // Checkpoint Loader
    if (opts.model) {
      this.setNodeValue(workflow, "checkpoint", "ckpt_name", opts.model);
    }

    return workflow;
  }

  buildImg2Img(opts: {
    input_image: string;
    prompt: string;
    negative_prompt?: string;
    denoise_strength: number;
    model?: string;
    steps: number;
    cfg_scale: number;
    seed?: number;
  }): any {
    const template = this.loadWorkflow("img2img.json");
    const workflow = JSON.parse(JSON.stringify(template));

    // TODO: img2img 워크플로 노드에 값 주입
    // 이미지는 ComfyUI에 먼저 업로드 후 참조
    return workflow;
  }

  buildUpscale(opts: { input_image: string }): any {
    const template = this.loadWorkflow("upscale.json");
    return JSON.parse(JSON.stringify(template));
  }

  buildRemoveBg(opts: { input_image: string }): any {
    const template = this.loadWorkflow("remove-bg.json");
    return JSON.parse(JSON.stringify(template));
  }

  // ── ComfyUI API 호출 ──

  async queuePrompt(workflow: any): Promise<ComfyResult> {
    const startTime = Date.now();

    // 1) 프롬프트 큐잉
    const queueRes = await fetch(`${this.baseUrl}/prompt`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        prompt: workflow,
        client_id: this.clientId,
      }),
    });

    if (!queueRes.ok) {
      throw new Error(`ComfyUI 큐잉 실패: ${await queueRes.text()}`);
    }

    const { prompt_id } = await queueRes.json() as any;

    // 2) WebSocket으로 완료 대기
    const images = await this.waitForCompletion(prompt_id);

    return {
      images,
      execution_time: (Date.now() - startTime) / 1000,
    };
  }

  // ── WebSocket 완료 대기 ──
  private waitForCompletion(promptId: string): Promise<Array<{ base64: string }>> {
    return new Promise((resolve, reject) => {
      const ws = new WebSocket(`${this.wsUrl}?clientId=${this.clientId}`);
      const timeout = setTimeout(() => {
        ws.close();
        reject(new Error("ComfyUI 실행 타임아웃 (5분)"));
      }, 300_000);

      ws.on("message", async (data) => {
        try {
          const msg = JSON.parse(data.toString());

          if (msg.type === "executed" && msg.data?.prompt_id === promptId) {
            clearTimeout(timeout);
            ws.close();

            // 히스토리에서 결과 이미지 가져오기
            const images = await this.fetchResultImages(promptId);
            resolve(images);
          }

          if (msg.type === "execution_error") {
            clearTimeout(timeout);
            ws.close();
            reject(new Error(`ComfyUI 실행 오류: ${JSON.stringify(msg.data)}`));
          }
        } catch (e) { /* non-JSON message, ignore */ }
      });

      ws.on("error", (err) => {
        clearTimeout(timeout);
        reject(new Error(`WebSocket 오류: ${err.message}`));
      });
    });
  }

  // ── 결과 이미지 다운로드 ──
  private async fetchResultImages(promptId: string): Promise<Array<{ base64: string }>> {
    const historyRes = await fetch(`${this.baseUrl}/history/${promptId}`);
    const history = await historyRes.json() as any;
    const outputs = history[promptId]?.outputs || {};

    const images: Array<{ base64: string }> = [];

    for (const nodeId of Object.keys(outputs)) {
      const nodeOutput = outputs[nodeId];
      if (nodeOutput.images) {
        for (const img of nodeOutput.images) {
          const imgRes = await fetch(
            `${this.baseUrl}/view?filename=${img.filename}&subfolder=${img.subfolder || ""}&type=${img.type || "output"}`
          );
          const buffer = Buffer.from(await imgRes.arrayBuffer());
          images.push({ base64: buffer.toString("base64") });
        }
      }
    }

    return images;
  }

  // ── 유틸 ──
  private loadWorkflow(filename: string): any {
    const filepath = path.join(WORKFLOWS_DIR, filename);
    if (!fs.existsSync(filepath)) {
      throw new Error(`워크플로 파일을 찾을 수 없습니다: ${filepath}`);
    }
    return JSON.parse(fs.readFileSync(filepath, "utf-8"));
  }

  private setNodeValue(workflow: any, nodeTitle: string, inputName: string, value: any) {
    // 노드 타이틀로 검색하여 값 주입
    for (const [nodeId, node] of Object.entries(workflow) as any[]) {
      if (node._meta?.title === nodeTitle || node.class_type === nodeTitle) {
        if (node.inputs) node.inputs[inputName] = value;
        return;
      }
    }
  }
}
