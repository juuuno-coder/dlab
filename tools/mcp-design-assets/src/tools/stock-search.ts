/**
 * Tool: stock_search
 * 무료 스톡 사이트(Unsplash, Pexels, Pixabay) 통합 검색
 */
import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { UnsplashClient } from "../providers/unsplash.js";
import { PexelsClient } from "../providers/pexels.js";
import { PixabayClient } from "../providers/pixabay.js";

export interface StockSearchResult {
  id: string;
  source: "unsplash" | "pexels" | "pixabay";
  thumbnail_url: string;
  full_url: string;
  download_url: string;   // 다운로드용 URL (stock_download에서 사용)
  width: number;
  height: number;
  description: string;
  photographer: string;
  license: string;
}

export function registerStockSearch(server: McpServer) {
  server.tool(
    "stock_search",

    "무료 스톡 이미지를 검색합니다. " +
    "Unsplash, Pexels, Pixabay를 동시에 검색하여 통합 결과를 반환합니다. " +
    "PPT에 사용할 사진, 배경 이미지, 아이콘 소스를 찾을 때 사용합니다. " +
    "검색어는 영어로 작성하면 결과가 풍부합니다.",

    {
      query: z.string().describe(
        "검색 키워드 (영어 권장). 예: 'ocean sunset busan', 'maritime ship port'"
      ),
      sources: z.array(
        z.enum(["unsplash", "pexels", "pixabay"])
      ).default(["unsplash", "pexels", "pixabay"]).describe(
        "검색할 스톡 사이트. 기본: 전체"
      ),
      orientation: z.enum(["landscape", "portrait", "squarish", "any"]).default("any").describe(
        "이미지 방향. PPT 배경: landscape, 프로필: portrait"
      ),
      color: z.string().optional().describe(
        "주요 색상 필터. 예: 'blue', 'gold', '#0F1B33'"
      ),
      per_page: z.number().min(1).max(30).default(10).describe(
        "사이트당 결과 수"
      ),
      min_width: z.number().optional().describe(
        "최소 너비 (px). PPT 배경용이면 1920 이상 권장"
      ),
      category: z.enum([
        "any", "backgrounds", "fashion", "nature", "science",
        "education", "feelings", "health", "people", "religion",
        "places", "animals", "industry", "computer", "food",
        "sports", "transportation", "travel", "buildings", "business", "music"
      ]).default("any").describe(
        "카테고리 필터 (Pixabay 전용, 다른 소스에서는 무시)"
      ),
    },

    async (params) => {
      try {
        const results: StockSearchResult[] = [];
        const errors: string[] = [];

        // 병렬로 각 소스 검색
        const promises = params.sources.map(async (source) => {
          try {
            switch (source) {
              case "unsplash": {
                const client = new UnsplashClient();
                const items = await client.search({
                  query: params.query,
                  orientation: params.orientation !== "any" ? params.orientation : undefined,
                  color: params.color,
                  per_page: params.per_page,
                });
                results.push(...items);
                break;
              }
              case "pexels": {
                const client = new PexelsClient();
                const items = await client.search({
                  query: params.query,
                  orientation: params.orientation !== "any" ? params.orientation : undefined,
                  color: params.color,
                  per_page: params.per_page,
                });
                results.push(...items);
                break;
              }
              case "pixabay": {
                const client = new PixabayClient();
                const items = await client.search({
                  query: params.query,
                  orientation: params.orientation !== "any" ? params.orientation : undefined,
                  category: params.category !== "any" ? params.category : undefined,
                  min_width: params.min_width,
                  per_page: params.per_page,
                });
                results.push(...items);
                break;
              }
            }
          } catch (e: any) {
            errors.push(`${source}: ${e.message}`);
          }
        });

        await Promise.all(promises);

        // min_width 필터 적용
        const filtered = params.min_width
          ? results.filter(r => r.width >= params.min_width!)
          : results;

        return {
          content: [{
            type: "text" as const,
            text: JSON.stringify({
              success: true,
              total: filtered.length,
              query: params.query,
              results: filtered.map(r => ({
                id: r.id,
                source: r.source,
                thumbnail: r.thumbnail_url,
                size: `${r.width}x${r.height}`,
                description: r.description,
                photographer: r.photographer,
                // download_url은 stock_download 도구에서 사용
                download_id: `${r.source}:${r.id}`,
              })),
              errors: errors.length ? errors : undefined,
              message: `${filtered.length}개 이미지를 찾았습니다. stock_download 도구로 다운로드하세요.`,
            }, null, 2),
          }],
        };
      } catch (error: any) {
        return {
          content: [{ type: "text" as const, text: `스톡 검색 실패: ${error.message}` }],
          isError: true,
        };
      }
    }
  );
}
