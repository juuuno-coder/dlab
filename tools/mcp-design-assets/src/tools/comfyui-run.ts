/**
 * Tool: comfyui_run
 * ComfyUI 워크플로 실행 (다양한 생성형 AI 모델 제어)
 */
import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { ComfyUIClient } from "../providers/comfyui.js";
import { saveGeneratedImage } from "../utils/file-manager.js";

export function registerComfyUIRun(server: McpServer) {
  server.tool(
    "comfyui_run",

    "ComfyUI 워크플로를 실행하여 이미지를 생성/변환합니다. " +
    "txt2img(텍스트→이미지), img2img(스타일 변환), upscale(고해상도화), " +
    "remove-bg(배경제거) 등의 워크플로를 지원합니다. " +
    "커스텀 워크플로 JSON도 직접 전달할 수 있습니다.",

    {
      // 사전 정의 워크플로 또는 커스텀
      workflow: z.enum([
        "txt2img", "img2img", "upscale", "remove-bg", "custom"
      ]).describe(
        "실행할 워크플로 유형"
      ),

      // txt2img / img2img 공통
      prompt: z.string().optional().describe(
        "생성 프롬프트 (txt2img, img2img에서 사용)"
      ),
      negative_prompt: z.string().optional().describe(
        "네거티브 프롬프트"
      ),

      // img2img / upscale / remove-bg 에서 사용
      input_image: z.string().optional().describe(
        "입력 이미지 경로. img2img, upscale, remove-bg에서 필수"
      ),

      // img2img 전용
      denoise_strength: z.number().min(0).max(1).default(0.7).describe(
        "img2img 디노이즈 강도. 0=원본 유지, 1=완전히 새로 생성"
      ),

      // 공통 설정
      model: z.string().optional().describe(
        "사용할 체크포인트 모델명. 예: 'sd_xl_base_1.0.safetensors'"
      ),
      width: z.number().min(256).max(2048).optional().describe("출력 너비"),
      height: z.number().min(256).max(2048).optional().describe("출력 높이"),
      steps: z.number().min(1).max(100).default(20).describe("샘플링 스텝 수"),
      cfg_scale: z.number().min(1).max(30).default(7).describe("CFG 스케일"),
      seed: z.number().optional().describe("시드 값"),

      // 커스텀 워크플로
      custom_workflow_json: z.string().optional().describe(
        "custom 타입일 때 ComfyUI API 포맷 JSON 문자열"
      ),

      output_format: z.enum(["png", "jpg", "webp"]).default("png"),
    },

    async (params) => {
      try {
        const client = new ComfyUIClient();

        // 워크플로 빌드
        let workflowData: any;

        switch (params.workflow) {
          case "txt2img":
            if (!params.prompt) throw new Error("txt2img에는 prompt가 필요합니다");
            workflowData = client.buildTxt2Img({
              prompt: params.prompt,
              negative_prompt: params.negative_prompt,
              model: params.model,
              width: params.width || 1024,
              height: params.height || 768,
              steps: params.steps,
              cfg_scale: params.cfg_scale,
              seed: params.seed,
            });
            break;

          case "img2img":
            if (!params.input_image) throw new Error("img2img에는 input_image가 필요합니다");
            workflowData = client.buildImg2Img({
              input_image: params.input_image,
              prompt: params.prompt || "",
              negative_prompt: params.negative_prompt,
              denoise_strength: params.denoise_strength,
              model: params.model,
              steps: params.steps,
              cfg_scale: params.cfg_scale,
              seed: params.seed,
            });
            break;

          case "upscale":
            if (!params.input_image) throw new Error("upscale에는 input_image가 필요합니다");
            workflowData = client.buildUpscale({ input_image: params.input_image });
            break;

          case "remove-bg":
            if (!params.input_image) throw new Error("remove-bg에는 input_image가 필요합니다");
            workflowData = client.buildRemoveBg({ input_image: params.input_image });
            break;

          case "custom":
            if (!params.custom_workflow_json) throw new Error("custom에는 custom_workflow_json이 필요합니다");
            workflowData = JSON.parse(params.custom_workflow_json);
            break;
        }

        // ComfyUI에 워크플로 전송 및 실행
        const result = await client.queuePrompt(workflowData);

        // 결과 이미지 저장
        const savedPaths: string[] = [];
        for (let i = 0; i < result.images.length; i++) {
          const path = await saveGeneratedImage(
            result.images[i].base64,
            params.output_format,
            `comfyui_${params.workflow}_${Date.now()}_${i}`
          );
          savedPaths.push(path);
        }

        return {
          content: [{
            type: "text" as const,
            text: JSON.stringify({
              success: true,
              workflow: params.workflow,
              images: savedPaths.map(p => ({ path: p })),
              execution_time: result.execution_time,
              message: `ComfyUI ${params.workflow} 완료. ${savedPaths.length}개 이미지 생성.`,
            }, null, 2),
          }],
        };
      } catch (error: any) {
        return {
          content: [{ type: "text" as const, text: `ComfyUI 실행 실패: ${error.message}` }],
          isError: true,
        };
      }
    }
  );
}
