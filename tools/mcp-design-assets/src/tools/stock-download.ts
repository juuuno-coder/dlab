/**
 * Tool: stock_download
 * 스톡 이미지 다운로드 + 선택적 리사이즈
 */
import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { UnsplashClient } from "../providers/unsplash.js";
import { PexelsClient } from "../providers/pexels.js";
import { PixabayClient } from "../providers/pixabay.js";
import { downloadAndSave, resizeImage } from "../utils/file-manager.js";

export function registerStockDownload(server: McpServer) {
  server.tool(
    "stock_download",

    "stock_search 결과에서 이미지를 다운로드합니다. " +
    "다운로드 시 리사이즈, 포맷 변환이 가능합니다. " +
    "반환되는 로컬 파일 경로를 PPT 스크립트에서 slide.addImage({ path }) 로 사용할 수 있습니다.",

    {
      download_id: z.string().describe(
        "stock_search 결과의 download_id. 형식: 'source:id' 예: 'unsplash:abc123'"
      ),
      resize_width: z.number().optional().describe(
        "다운로드 후 리사이즈할 너비 (px). 미지정 시 원본 크기"
      ),
      resize_height: z.number().optional().describe(
        "다운로드 후 리사이즈할 높이 (px). 미지정 시 비율 유지"
      ),
      output_format: z.enum(["png", "jpg", "webp"]).default("jpg").describe(
        "저장 포맷"
      ),
      quality: z.number().min(1).max(100).default(90).describe(
        "JPG/WebP 압축 품질 (1-100)"
      ),
    },

    async (params) => {
      try {
        const [source, id] = params.download_id.split(":");
        if (!source || !id) throw new Error("잘못된 download_id 형식입니다. 'source:id' 형식이어야 합니다.");

        // 소스별 다운로드 URL 획득
        let downloadUrl: string;
        let photographer: string = "";

        switch (source) {
          case "unsplash": {
            const client = new UnsplashClient();
            const photo = await client.getDownloadUrl(id);
            downloadUrl = photo.url;
            photographer = photo.photographer;
            // Unsplash API 가이드라인: 다운로드 트리거 호출
            await client.triggerDownload(id);
            break;
          }
          case "pexels": {
            const client = new PexelsClient();
            const photo = await client.getDownloadUrl(id);
            downloadUrl = photo.url;
            photographer = photo.photographer;
            break;
          }
          case "pixabay": {
            const client = new PixabayClient();
            const photo = await client.getDownloadUrl(id);
            downloadUrl = photo.url;
            photographer = photo.photographer;
            break;
          }
          default:
            throw new Error(`지원하지 않는 소스: ${source}`);
        }

        // 다운로드
        const rawPath = await downloadAndSave(downloadUrl, `stock_${source}_${id}`);

        // 리사이즈 (옵션)
        let finalPath = rawPath;
        if (params.resize_width || params.resize_height) {
          finalPath = await resizeImage(rawPath, {
            width: params.resize_width,
            height: params.resize_height,
            format: params.output_format,
            quality: params.quality,
          });
        }

        return {
          content: [{
            type: "text" as const,
            text: JSON.stringify({
              success: true,
              path: finalPath,
              source,
              photographer,
              license: source === "unsplash" ? "Unsplash License" :
                       source === "pexels" ? "Pexels License (free)" :
                       "Pixabay License (free)",
              attribution_required: source === "unsplash",
              message: `이미지 다운로드 완료: ${finalPath}`,
            }, null, 2),
          }],
        };
      } catch (error: any) {
        return {
          content: [{ type: "text" as const, text: `다운로드 실패: ${error.message}` }],
          isError: true,
        };
      }
    }
  );
}
