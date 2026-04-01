/**
 * Tool: asset_list / asset_cleanup
 * 생성/다운로드된 에셋 관리
 */
import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { listAssets, cleanupAssets, getAssetInfo } from "../utils/file-manager.js";

export function registerAssetManage(server: McpServer) {

  // ── asset_list: 현재 에셋 목록 조회 ──
  server.tool(
    "asset_list",

    "생성/다운로드된 이미지 에셋 목록을 조회합니다. " +
    "카테고리별(generated, stock, processed)로 필터링 가능합니다.",

    {
      category: z.enum(["all", "generated", "stock", "processed"]).default("all").describe(
        "에셋 카테고리. generated: AI 생성, stock: 스톡 다운로드, processed: 후처리"
      ),
      sort_by: z.enum(["date", "name", "size"]).default("date").describe("정렬 기준"),
    },

    async (params) => {
      try {
        const assets = await listAssets(params.category, params.sort_by);

        return {
          content: [{
            type: "text" as const,
            text: JSON.stringify({
              total: assets.length,
              assets: assets.map(a => ({
                path: a.path,
                filename: a.filename,
                category: a.category,
                size_kb: Math.round(a.size / 1024),
                dimensions: a.dimensions ? `${a.dimensions.width}x${a.dimensions.height}` : "unknown",
                created: a.created,
              })),
            }, null, 2),
          }],
        };
      } catch (error: any) {
        return {
          content: [{ type: "text" as const, text: `에셋 목록 조회 실패: ${error.message}` }],
          isError: true,
        };
      }
    }
  );

  // ── asset_cleanup: 오래된 에셋 정리 ──
  server.tool(
    "asset_cleanup",

    "오래된 에셋 파일을 정리합니다. 디스크 공간 확보에 사용합니다.",

    {
      older_than_hours: z.number().default(24).describe(
        "이 시간(hour)보다 오래된 파일 삭제. 기본: 24시간"
      ),
      category: z.enum(["all", "generated", "stock", "processed"]).default("all"),
      dry_run: z.boolean().default(true).describe(
        "true: 삭제 대상만 확인 (삭제 안 함). false: 실제 삭제"
      ),
    },

    async (params) => {
      try {
        const result = await cleanupAssets({
          olderThanHours: params.older_than_hours,
          category: params.category,
          dryRun: params.dry_run,
        });

        return {
          content: [{
            type: "text" as const,
            text: JSON.stringify({
              dry_run: params.dry_run,
              files_affected: result.count,
              space_freed_mb: Math.round(result.totalSize / 1024 / 1024 * 10) / 10,
              message: params.dry_run
                ? `${result.count}개 파일이 삭제 대상입니다. dry_run=false로 실제 삭제하세요.`
                : `${result.count}개 파일을 삭제했습니다.`,
            }, null, 2),
          }],
        };
      } catch (error: any) {
        return {
          content: [{ type: "text" as const, text: `정리 실패: ${error.message}` }],
          isError: true,
        };
      }
    }
  );
}
