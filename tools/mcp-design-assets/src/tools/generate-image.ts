/**
 * Tool: generate_image
 * 나노바나나2 API를 통한 AI 이미지 생성
 */
import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { NanobanaClient } from "../providers/nanobana.js";
import { saveGeneratedImage } from "../utils/file-manager.js";

export function registerGenerateImage(server: McpServer) {
  server.tool(
    // ── 도구 이름 ──
    "generate_image",

    // ── 도구 설명 (클로드가 언제 이 도구를 호출할지 판단하는 기준) ──
    "나노바나나2 API로 AI 이미지를 생성합니다. " +
    "PPT 배경, 일러스트, 아이콘, 컨셉 이미지 등을 만들 때 사용합니다. " +
    "프롬프트는 영어로 작성하는 것이 품질이 좋습니다.",

    // ── 입력 스키마 ──
    {
      prompt: z.string().describe(
        "이미지 생성 프롬프트 (영어 권장). 예: 'maritime sunset with lighthouse, golden hour, cinematic'"
      ),
      negative_prompt: z.string().optional().describe(
        "제외할 요소. 예: 'blurry, low quality, text, watermark'"
      ),
      width: z.number().min(256).max(2048).default(1024).describe(
        "이미지 너비 (px). PPT 전체 배경: 1920, 카드 이미지: 1024"
      ),
      height: z.number().min(256).max(2048).default(768).describe(
        "이미지 높이 (px). PPT 배경: 1080, 정사각형: 1024"
      ),
      model: z.enum(["nanobana2-default", "nanobana2-xl", "nanobana2-fast"]).default("nanobana2-default").describe(
        "사용할 모델. default: 일반, xl: 고품질, fast: 빠른 생성"
      ),
      style: z.enum([
        "photorealistic", "illustration", "watercolor", "flat-design",
        "3d-render", "anime", "sketch", "infographic", "none"
      ]).default("none").describe(
        "적용할 스타일 프리셋"
      ),
      num_images: z.number().min(1).max(4).default(1).describe(
        "생성할 이미지 수 (1~4)"
      ),
      seed: z.number().optional().describe(
        "재현성을 위한 시드 값. 같은 시드 = 같은 결과"
      ),
      output_format: z.enum(["png", "jpg", "webp"]).default("png").describe(
        "출력 포맷. PPT 삽입용은 png 권장"
      ),
    },

    // ── 핸들러 ──
    async (params) => {
      try {
        const client = new NanobanaClient();

        // 스타일 프리셋 → 프롬프트 보강
        const enhancedPrompt = applyStylePreset(params.prompt, params.style);

        const result = await client.generate({
          prompt: enhancedPrompt,
          negative_prompt: params.negative_prompt || "blurry, low quality, text, watermark, deformed",
          width: params.width,
          height: params.height,
          model: params.model,
          num_images: params.num_images,
          seed: params.seed,
        });

        // 파일 저장
        const savedPaths: string[] = [];
        for (let i = 0; i < result.images.length; i++) {
          const path = await saveGeneratedImage(
            result.images[i].base64,
            params.output_format,
            `nanobana_${Date.now()}_${i}`
          );
          savedPaths.push(path);
        }

        return {
          content: [
            {
              type: "text" as const,
              text: JSON.stringify({
                success: true,
                images: savedPaths.map((p, i) => ({
                  path: p,
                  width: params.width,
                  height: params.height,
                  seed: result.images[i].seed,
                })),
                prompt_used: enhancedPrompt,
                model: params.model,
                message: `${savedPaths.length}개 이미지가 생성되었습니다.`,
              }, null, 2),
            },
          ],
        };
      } catch (error: any) {
        return {
          content: [{ type: "text" as const, text: `이미지 생성 실패: ${error.message}` }],
          isError: true,
        };
      }
    }
  );
}

// ── 스타일 프리셋을 프롬프트에 반영 ──
function applyStylePreset(prompt: string, style: string): string {
  const presets: Record<string, string> = {
    "photorealistic": "photorealistic, 8k uhd, high detail, professional photography",
    "illustration": "digital illustration, clean lines, vibrant colors, professional artwork",
    "watercolor": "watercolor painting style, soft edges, artistic, hand-painted feel",
    "flat-design": "flat design, minimal, vector style, clean geometric shapes, solid colors",
    "3d-render": "3D render, cinema 4D, octane render, smooth lighting, professional",
    "anime": "anime style, cel shaded, vibrant, detailed, studio quality",
    "sketch": "pencil sketch, hand-drawn, line art, detailed illustration",
    "infographic": "infographic style, clean, data visualization, professional, minimal",
    "none": "",
  };

  const suffix = presets[style] || "";
  return suffix ? `${prompt}, ${suffix}` : prompt;
}
