# MCP Design Assets Server — 전체 코드 & 설계 레퍼런스

> 나노바나나2 + ComfyUI + 스톡이미지(Unsplash/Pexels/Pixabay) 통합 MCP 서버
> 클로드코드(안티그래비티) & 클로드 코워크 연동용

---

## 목차

1. [프로젝트 구조](#1-프로젝트-구조)
2. [환경 설정](#2-환경-설정)
3. [서버 진입점 — index.ts](#3-서버-진입점--indexts)
4. [도구 등록 허브 — tools/index.ts](#4-도구-등록-허브--toolsindexts)
5. [Tool: generate_image — 나노바나나2 이미지 생성](#5-tool-generate_image--나노바나나2-이미지-생성)
6. [Tool: comfyui_run — ComfyUI 워크플로 실행](#6-tool-comfyui_run--comfyui-워크플로-실행)
7. [Tool: stock_search — 스톡 이미지 통합 검색](#7-tool-stock_search--스톡-이미지-통합-검색)
8. [Tool: stock_download — 스톡 이미지 다운로드](#8-tool-stock_download--스톡-이미지-다운로드)
9. [Tool: asset_list / asset_cleanup — 에셋 관리](#9-tool-asset_list--asset_cleanup--에셋-관리)
10. [Provider: 나노바나나2 클라이언트](#10-provider-나노바나나2-클라이언트)
11. [Provider: ComfyUI 클라이언트](#11-provider-comfyui-클라이언트)
12. [Provider: Unsplash 클라이언트](#12-provider-unsplash-클라이언트)
13. [Provider: Pexels 클라이언트](#13-provider-pexels-클라이언트)
14. [Provider: Pixabay 클라이언트](#14-provider-pixabay-클라이언트)
15. [유틸: 파일 관리자](#15-유틸-파일-관리자)
16. [package.json & tsconfig.json](#16-packagejson--tsconfigjson)
17. [설치 & 연동 가이드](#17-설치--연동-가이드)
18. [사용 시나리오](#18-사용-시나리오)
19. [TODO: 커스터마이징 포인트](#19-todo-커스터마이징-포인트)

---

## 1. 프로젝트 구조

```
mcp-design-assets/
├── package.json
├── tsconfig.json
├── .env.example              # API 키 템플릿
├── .env                      # 실제 API 키 (gitignore)
│
├── src/
│   ├── index.ts              # MCP 서버 진입점 (stdio/SSE)
│   │
│   ├── tools/                # 도구 정의 (각 도구별 모듈)
│   │   ├── index.ts          # 모든 도구 등록/내보내기
│   │   ├── generate-image.ts # 나노바나나2 이미지 생성
│   │   ├── comfyui-run.ts    # ComfyUI 워크플로 실행
│   │   ├── stock-search.ts   # 스톡 이미지 검색
│   │   ├── stock-download.ts # 스톡 이미지 다운로드
│   │   └── asset-manage.ts   # 에셋 목록/삭제/정리
│   │
│   ├── providers/            # 외부 API 연동 레이어
│   │   ├── nanobana.ts       # 나노바나나2 API 클라이언트
│   │   ├── comfyui.ts        # ComfyUI WebSocket 클라이언트
│   │   ├── unsplash.ts       # Unsplash API
│   │   ├── pexels.ts         # Pexels API
│   │   └── pixabay.ts        # Pixabay API
│   │
│   ├── workflows/            # ComfyUI 워크플로 JSON 템플릿
│   │   ├── txt2img.json
│   │   ├── img2img.json
│   │   ├── upscale.json
│   │   └── remove-bg.json
│   │
│   └── utils/
│       └── file-manager.ts   # 저장, 리사이즈, 캐싱, 정리
│
└── assets/                   # 생성/다운로드된 이미지 저장소
    ├── generated/
    ├── stock/
    └── processed/
```

---

## 2. 환경 설정

파일: `.env.example`

```bash
# ── 나노바나나2 ──
NANOBANA_API_KEY=your_nanobana_api_key_here
NANOBANA_API_URL=https://api.nanobana2.example.com/v1

# ── ComfyUI ──
COMFYUI_HOST=127.0.0.1
COMFYUI_PORT=8188

# ── Unsplash (무료: 50 req/hour) ──
UNSPLASH_ACCESS_KEY=your_unsplash_access_key_here

# ── Pexels (무료: 200 req/hour) ──
PEXELS_API_KEY=your_pexels_api_key_here

# ── Pixabay (무료: 100 req/minute) ──
PIXABAY_API_KEY=your_pixabay_api_key_here

# ── 에셋 저장 경로 (선택) ──
# ASSETS_DIR=/path/to/custom/assets/folder
```

---

## 3. 서버 진입점 — index.ts

파일: `src/index.ts`

```typescript
#!/usr/bin/env node
/**
 * MCP Design Assets Server
 * 나노바나나2 + ComfyUI + 스톡이미지 통합 MCP 서버
 *
 * 실행 방식:
 *   stdio:  node dist/index.js
 *   SSE:    node dist/index.js --sse --port 3100
 */
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
// import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
import { registerAllTools } from "./tools/index.js";
import dotenv from "dotenv";

dotenv.config();

const server = new McpServer({
  name: "design-assets",
  version: "1.0.0",
  description: "AI 이미지 생성 + 스톡이미지 검색/다운로드 + ComfyUI 워크플로 실행",
});

// ── 모든 도구 등록 ──
registerAllTools(server);

// ── 서버 시작 ──
async function main() {
  const args = process.argv.slice(2);

  if (args.includes("--sse")) {
    const port = parseInt(args[args.indexOf("--port") + 1] || "3100");
    console.error(`[design-assets] SSE mode on port ${port}`);
    // SSE transport 구현은 @modelcontextprotocol/sdk 참조
  } else {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error("[design-assets] stdio mode started");
  }
}

main().catch(console.error);
```

---

## 4. 도구 등록 허브 — tools/index.ts

파일: `src/tools/index.ts`

```typescript
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { registerGenerateImage } from "./generate-image.js";
import { registerComfyUIRun } from "./comfyui-run.js";
import { registerStockSearch } from "./stock-search.js";
import { registerStockDownload } from "./stock-download.js";
import { registerAssetManage } from "./asset-manage.js";

export function registerAllTools(server: McpServer) {
  registerGenerateImage(server);
  registerComfyUIRun(server);
  registerStockSearch(server);
  registerStockDownload(server);
  registerAssetManage(server);
}
```

---

## 5. Tool: generate_image — 나노바나나2 이미지 생성

파일: `src/tools/generate-image.ts`

```typescript
import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { NanobanaClient } from "../providers/nanobana.js";
import { saveGeneratedImage } from "../utils/file-manager.js";

export function registerGenerateImage(server: McpServer) {
  server.tool(
    "generate_image",

    "나노바나나2 API로 AI 이미지를 생성합니다. " +
    "PPT 배경, 일러스트, 아이콘, 컨셉 이미지 등을 만들 때 사용합니다. " +
    "프롬프트는 영어로 작성하는 것이 품질이 좋습니다.",

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
      num_images: z.number().min(1).max(4).default(1).describe("생성할 이미지 수 (1~4)"),
      seed: z.number().optional().describe("재현성을 위한 시드 값"),
      output_format: z.enum(["png", "jpg", "webp"]).default("png").describe("출력 포맷"),
    },

    async (params) => {
      try {
        const client = new NanobanaClient();
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

        const savedPaths: string[] = [];
        for (let i = 0; i < result.images.length; i++) {
          const path = await saveGeneratedImage(
            result.images[i].base64, params.output_format, `nanobana_${Date.now()}_${i}`
          );
          savedPaths.push(path);
        }

        return {
          content: [{
            type: "text" as const,
            text: JSON.stringify({
              success: true,
              images: savedPaths.map((p, i) => ({
                path: p, width: params.width, height: params.height, seed: result.images[i].seed,
              })),
              prompt_used: enhancedPrompt,
              model: params.model,
              message: `${savedPaths.length}개 이미지가 생성되었습니다.`,
            }, null, 2),
          }],
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
```

---

## 6. Tool: comfyui_run — ComfyUI 워크플로 실행

파일: `src/tools/comfyui-run.ts`

```typescript
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
      workflow: z.enum(["txt2img", "img2img", "upscale", "remove-bg", "custom"]).describe(
        "실행할 워크플로 유형"
      ),
      prompt: z.string().optional().describe("생성 프롬프트 (txt2img, img2img에서 사용)"),
      negative_prompt: z.string().optional().describe("네거티브 프롬프트"),
      input_image: z.string().optional().describe("입력 이미지 경로. img2img, upscale, remove-bg에서 필수"),
      denoise_strength: z.number().min(0).max(1).default(0.7).describe("img2img 디노이즈 강도"),
      model: z.string().optional().describe("체크포인트 모델명. 예: 'sd_xl_base_1.0.safetensors'"),
      width: z.number().min(256).max(2048).optional().describe("출력 너비"),
      height: z.number().min(256).max(2048).optional().describe("출력 높이"),
      steps: z.number().min(1).max(100).default(20).describe("샘플링 스텝 수"),
      cfg_scale: z.number().min(1).max(30).default(7).describe("CFG 스케일"),
      seed: z.number().optional().describe("시드 값"),
      custom_workflow_json: z.string().optional().describe("custom 타입일 때 ComfyUI API 포맷 JSON"),
      output_format: z.enum(["png", "jpg", "webp"]).default("png"),
    },

    async (params) => {
      try {
        const client = new ComfyUIClient();
        let workflowData: any;

        switch (params.workflow) {
          case "txt2img":
            if (!params.prompt) throw new Error("txt2img에는 prompt가 필요합니다");
            workflowData = client.buildTxt2Img({
              prompt: params.prompt, negative_prompt: params.negative_prompt,
              model: params.model, width: params.width || 1024, height: params.height || 768,
              steps: params.steps, cfg_scale: params.cfg_scale, seed: params.seed,
            });
            break;
          case "img2img":
            if (!params.input_image) throw new Error("img2img에는 input_image가 필요합니다");
            workflowData = client.buildImg2Img({
              input_image: params.input_image, prompt: params.prompt || "",
              negative_prompt: params.negative_prompt, denoise_strength: params.denoise_strength,
              model: params.model, steps: params.steps, cfg_scale: params.cfg_scale, seed: params.seed,
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

        const result = await client.queuePrompt(workflowData);

        const savedPaths: string[] = [];
        for (let i = 0; i < result.images.length; i++) {
          const path = await saveGeneratedImage(
            result.images[i].base64, params.output_format, `comfyui_${params.workflow}_${Date.now()}_${i}`
          );
          savedPaths.push(path);
        }

        return {
          content: [{
            type: "text" as const,
            text: JSON.stringify({
              success: true, workflow: params.workflow,
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
```

---

## 7. Tool: stock_search — 스톡 이미지 통합 검색

파일: `src/tools/stock-search.ts`

```typescript
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
  download_url: string;
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
      query: z.string().describe("검색 키워드 (영어 권장)"),
      sources: z.array(z.enum(["unsplash", "pexels", "pixabay"]))
        .default(["unsplash", "pexels", "pixabay"]).describe("검색할 스톡 사이트"),
      orientation: z.enum(["landscape", "portrait", "squarish", "any"]).default("any")
        .describe("이미지 방향. PPT 배경: landscape"),
      color: z.string().optional().describe("주요 색상 필터. 예: 'blue', 'gold'"),
      per_page: z.number().min(1).max(30).default(10).describe("사이트당 결과 수"),
      min_width: z.number().optional().describe("최소 너비 (px). PPT 배경용: 1920+"),
      category: z.enum([
        "any", "backgrounds", "fashion", "nature", "science", "education",
        "feelings", "health", "people", "religion", "places", "animals",
        "industry", "computer", "food", "sports", "transportation",
        "travel", "buildings", "business", "music"
      ]).default("any").describe("카테고리 필터 (Pixabay 전용)"),
    },

    async (params) => {
      try {
        const results: StockSearchResult[] = [];
        const errors: string[] = [];

        const promises = params.sources.map(async (source) => {
          try {
            switch (source) {
              case "unsplash": {
                const client = new UnsplashClient();
                const items = await client.search({
                  query: params.query,
                  orientation: params.orientation !== "any" ? params.orientation : undefined,
                  color: params.color, per_page: params.per_page,
                });
                results.push(...items);
                break;
              }
              case "pexels": {
                const client = new PexelsClient();
                const items = await client.search({
                  query: params.query,
                  orientation: params.orientation !== "any" ? params.orientation : undefined,
                  color: params.color, per_page: params.per_page,
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
                  min_width: params.min_width, per_page: params.per_page,
                });
                results.push(...items);
                break;
              }
            }
          } catch (e: any) { errors.push(`${source}: ${e.message}`); }
        });
        await Promise.all(promises);

        const filtered = params.min_width
          ? results.filter(r => r.width >= params.min_width!) : results;

        return {
          content: [{
            type: "text" as const,
            text: JSON.stringify({
              success: true, total: filtered.length, query: params.query,
              results: filtered.map(r => ({
                id: r.id, source: r.source, thumbnail: r.thumbnail_url,
                size: `${r.width}x${r.height}`, description: r.description,
                photographer: r.photographer, download_id: `${r.source}:${r.id}`,
              })),
              errors: errors.length ? errors : undefined,
              message: `${filtered.length}개 이미지를 찾았습니다. stock_download로 다운로드하세요.`,
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
```

---

## 8. Tool: stock_download — 스톡 이미지 다운로드

파일: `src/tools/stock-download.ts`

```typescript
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
      download_id: z.string().describe("stock_search의 download_id. 형식: 'source:id'"),
      resize_width: z.number().optional().describe("리사이즈 너비 (px)"),
      resize_height: z.number().optional().describe("리사이즈 높이 (px)"),
      output_format: z.enum(["png", "jpg", "webp"]).default("jpg"),
      quality: z.number().min(1).max(100).default(90).describe("JPG/WebP 압축 품질"),
    },

    async (params) => {
      try {
        const [source, id] = params.download_id.split(":");
        if (!source || !id) throw new Error("잘못된 download_id 형식");

        let downloadUrl: string;
        let photographer: string = "";

        switch (source) {
          case "unsplash": {
            const client = new UnsplashClient();
            const photo = await client.getDownloadUrl(id);
            downloadUrl = photo.url; photographer = photo.photographer;
            await client.triggerDownload(id);
            break;
          }
          case "pexels": {
            const client = new PexelsClient();
            const photo = await client.getDownloadUrl(id);
            downloadUrl = photo.url; photographer = photo.photographer;
            break;
          }
          case "pixabay": {
            const client = new PixabayClient();
            const photo = await client.getDownloadUrl(id);
            downloadUrl = photo.url; photographer = photo.photographer;
            break;
          }
          default: throw new Error(`지원하지 않는 소스: ${source}`);
        }

        const rawPath = await downloadAndSave(downloadUrl, `stock_${source}_${id}`);

        let finalPath = rawPath;
        if (params.resize_width || params.resize_height) {
          finalPath = await resizeImage(rawPath, {
            width: params.resize_width, height: params.resize_height,
            format: params.output_format, quality: params.quality,
          });
        }

        return {
          content: [{
            type: "text" as const,
            text: JSON.stringify({
              success: true, path: finalPath, source, photographer,
              license: source === "unsplash" ? "Unsplash License" :
                       source === "pexels" ? "Pexels License (free)" : "Pixabay License (free)",
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
```

---

## 9. Tool: asset_list / asset_cleanup — 에셋 관리

파일: `src/tools/asset-manage.ts`

```typescript
import { z } from "zod";
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { listAssets, cleanupAssets } from "../utils/file-manager.js";

export function registerAssetManage(server: McpServer) {

  server.tool(
    "asset_list",
    "생성/다운로드된 이미지 에셋 목록을 조회합니다.",
    {
      category: z.enum(["all", "generated", "stock", "processed"]).default("all"),
      sort_by: z.enum(["date", "name", "size"]).default("date"),
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
                path: a.path, filename: a.filename, category: a.category,
                size_kb: Math.round(a.size / 1024), created: a.created,
              })),
            }, null, 2),
          }],
        };
      } catch (error: any) {
        return { content: [{ type: "text" as const, text: `조회 실패: ${error.message}` }], isError: true };
      }
    }
  );

  server.tool(
    "asset_cleanup",
    "오래된 에셋 파일을 정리합니다.",
    {
      older_than_hours: z.number().default(24),
      category: z.enum(["all", "generated", "stock", "processed"]).default("all"),
      dry_run: z.boolean().default(true).describe("true: 미리보기, false: 실제 삭제"),
    },
    async (params) => {
      try {
        const result = await cleanupAssets({
          olderThanHours: params.older_than_hours,
          category: params.category, dryRun: params.dry_run,
        });
        return {
          content: [{
            type: "text" as const,
            text: JSON.stringify({
              dry_run: params.dry_run, files_affected: result.count,
              space_freed_mb: Math.round(result.totalSize / 1024 / 1024 * 10) / 10,
              message: params.dry_run
                ? `${result.count}개 파일 삭제 대상. dry_run=false로 실제 삭제.`
                : `${result.count}개 파일 삭제 완료.`,
            }, null, 2),
          }],
        };
      } catch (error: any) {
        return { content: [{ type: "text" as const, text: `정리 실패: ${error.message}` }], isError: true };
      }
    }
  );
}
```

---

## 10. Provider: 나노바나나2 클라이언트

파일: `src/providers/nanobana.ts`

```typescript
/**
 * 나노바나나2 API 클라이언트
 * TODO: 실제 API 스펙에 맞게 엔드포인트/파라미터/응답 매핑을 조정하세요
 */
export interface GenerateOptions {
  prompt: string;
  negative_prompt?: string;
  width: number;
  height: number;
  model: string;
  num_images: number;
  seed?: number;
}

export interface GenerateResult {
  images: Array<{ base64: string; seed: number }>;
}

export class NanobanaClient {
  private apiKey: string;
  private baseUrl: string;

  constructor() {
    this.apiKey = process.env.NANOBANA_API_KEY || "";
    this.baseUrl = process.env.NANOBANA_API_URL || "https://api.nanobana2.example.com/v1";
    if (!this.apiKey) throw new Error("NANOBANA_API_KEY 환경변수가 설정되지 않았습니다.");
  }

  async generate(options: GenerateOptions): Promise<GenerateResult> {
    const response = await fetch(`${this.baseUrl}/generate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        prompt: options.prompt,
        negative_prompt: options.negative_prompt,
        width: options.width,
        height: options.height,
        model: options.model,
        batch_size: options.num_images,
        seed: options.seed ?? -1,
        // TODO: 나노바나나2 고유 파라미터 (sampler, scheduler 등) 추가
      }),
    });

    if (!response.ok) {
      throw new Error(`나노바나나2 API 오류 (${response.status}): ${await response.text()}`);
    }

    const data = await response.json() as any;

    // TODO: 실제 응답 구조에 맞게 매핑 조정
    return {
      images: (data.images || data.results || []).map((img: any) => ({
        base64: img.base64 || img.b64_json || img.data,
        seed: img.seed || data.seed || 0,
      })),
    };
  }
}
```

---

## 11. Provider: ComfyUI 클라이언트

파일: `src/providers/comfyui.ts`

```typescript
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

  buildTxt2Img(opts: {
    prompt: string; negative_prompt?: string; model?: string;
    width: number; height: number; steps: number; cfg_scale: number; seed?: number;
  }): any {
    const template = this.loadWorkflow("txt2img.json");
    const workflow = JSON.parse(JSON.stringify(template));

    this.setNodeValue(workflow, "sampler", "seed", opts.seed ?? Math.floor(Math.random() * 2**32));
    this.setNodeValue(workflow, "sampler", "steps", opts.steps);
    this.setNodeValue(workflow, "sampler", "cfg", opts.cfg_scale);
    this.setNodeValue(workflow, "positive_prompt", "text", opts.prompt);
    this.setNodeValue(workflow, "negative_prompt", "text",
      opts.negative_prompt || "blurry, low quality, text, watermark");
    this.setNodeValue(workflow, "latent_image", "width", opts.width);
    this.setNodeValue(workflow, "latent_image", "height", opts.height);
    if (opts.model) this.setNodeValue(workflow, "checkpoint", "ckpt_name", opts.model);

    return workflow;
  }

  buildImg2Img(opts: {
    input_image: string; prompt: string; negative_prompt?: string;
    denoise_strength: number; model?: string; steps: number; cfg_scale: number; seed?: number;
  }): any {
    const template = this.loadWorkflow("img2img.json");
    // TODO: img2img 워크플로 노드에 값 주입
    return JSON.parse(JSON.stringify(template));
  }

  buildUpscale(opts: { input_image: string }): any {
    return JSON.parse(JSON.stringify(this.loadWorkflow("upscale.json")));
  }

  buildRemoveBg(opts: { input_image: string }): any {
    return JSON.parse(JSON.stringify(this.loadWorkflow("remove-bg.json")));
  }

  async queuePrompt(workflow: any): Promise<ComfyResult> {
    const startTime = Date.now();

    const queueRes = await fetch(`${this.baseUrl}/prompt`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: workflow, client_id: this.clientId }),
    });
    if (!queueRes.ok) throw new Error(`ComfyUI 큐잉 실패: ${await queueRes.text()}`);

    const { prompt_id } = await queueRes.json() as any;
    const images = await this.waitForCompletion(prompt_id);

    return { images, execution_time: (Date.now() - startTime) / 1000 };
  }

  private waitForCompletion(promptId: string): Promise<Array<{ base64: string }>> {
    return new Promise((resolve, reject) => {
      const ws = new WebSocket(`${this.wsUrl}?clientId=${this.clientId}`);
      const timeout = setTimeout(() => { ws.close(); reject(new Error("타임아웃 (5분)")); }, 300_000);

      ws.on("message", async (data) => {
        try {
          const msg = JSON.parse(data.toString());
          if (msg.type === "executed" && msg.data?.prompt_id === promptId) {
            clearTimeout(timeout); ws.close();
            resolve(await this.fetchResultImages(promptId));
          }
          if (msg.type === "execution_error") {
            clearTimeout(timeout); ws.close();
            reject(new Error(`실행 오류: ${JSON.stringify(msg.data)}`));
          }
        } catch (e) { /* non-JSON */ }
      });

      ws.on("error", (err) => { clearTimeout(timeout); reject(err); });
    });
  }

  private async fetchResultImages(promptId: string): Promise<Array<{ base64: string }>> {
    const historyRes = await fetch(`${this.baseUrl}/history/${promptId}`);
    const history = await historyRes.json() as any;
    const outputs = history[promptId]?.outputs || {};
    const images: Array<{ base64: string }> = [];

    for (const nodeId of Object.keys(outputs)) {
      if (outputs[nodeId].images) {
        for (const img of outputs[nodeId].images) {
          const imgRes = await fetch(
            `${this.baseUrl}/view?filename=${img.filename}&subfolder=${img.subfolder || ""}&type=${img.type || "output"}`
          );
          images.push({ base64: Buffer.from(await imgRes.arrayBuffer()).toString("base64") });
        }
      }
    }
    return images;
  }

  private loadWorkflow(filename: string): any {
    const filepath = path.join(WORKFLOWS_DIR, filename);
    if (!fs.existsSync(filepath)) throw new Error(`워크플로 없음: ${filepath}`);
    return JSON.parse(fs.readFileSync(filepath, "utf-8"));
  }

  private setNodeValue(workflow: any, nodeTitle: string, inputName: string, value: any) {
    for (const [_, node] of Object.entries(workflow) as any[]) {
      if (node._meta?.title === nodeTitle || node.class_type === nodeTitle) {
        if (node.inputs) node.inputs[inputName] = value;
        return;
      }
    }
  }
}
```

---

## 12. Provider: Unsplash 클라이언트

파일: `src/providers/unsplash.ts`

```typescript
import type { StockSearchResult } from "../tools/stock-search.js";
const BASE_URL = "https://api.unsplash.com";

export class UnsplashClient {
  private accessKey: string;
  constructor() {
    this.accessKey = process.env.UNSPLASH_ACCESS_KEY || "";
    if (!this.accessKey) throw new Error("UNSPLASH_ACCESS_KEY 미설정");
  }

  async search(opts: { query: string; orientation?: string; color?: string; per_page: number }): Promise<StockSearchResult[]> {
    const params = new URLSearchParams({ query: opts.query, per_page: String(opts.per_page) });
    if (opts.orientation) params.set("orientation", opts.orientation);
    if (opts.color) params.set("color", opts.color);

    const res = await fetch(`${BASE_URL}/search/photos?${params}`, {
      headers: { Authorization: `Client-ID ${this.accessKey}` },
    });
    if (!res.ok) throw new Error(`Unsplash ${res.status}`);
    const data = await res.json() as any;

    return data.results.map((p: any) => ({
      id: p.id, source: "unsplash" as const,
      thumbnail_url: p.urls.small, full_url: p.urls.full, download_url: p.links.download,
      width: p.width, height: p.height,
      description: p.description || p.alt_description || "",
      photographer: p.user.name, license: "Unsplash License",
    }));
  }

  async getDownloadUrl(id: string) {
    const res = await fetch(`${BASE_URL}/photos/${id}`, {
      headers: { Authorization: `Client-ID ${this.accessKey}` },
    });
    const data = await res.json() as any;
    return { url: data.links.download, photographer: data.user.name };
  }

  async triggerDownload(id: string) {
    await fetch(`${BASE_URL}/photos/${id}/download`, {
      headers: { Authorization: `Client-ID ${this.accessKey}` },
    });
  }
}
```

---

## 13. Provider: Pexels 클라이언트

파일: `src/providers/pexels.ts`

```typescript
import type { StockSearchResult } from "../tools/stock-search.js";
const BASE_URL = "https://api.pexels.com/v1";

export class PexelsClient {
  private apiKey: string;
  constructor() {
    this.apiKey = process.env.PEXELS_API_KEY || "";
    if (!this.apiKey) throw new Error("PEXELS_API_KEY 미설정");
  }

  async search(opts: { query: string; orientation?: string; color?: string; per_page: number }): Promise<StockSearchResult[]> {
    const params = new URLSearchParams({ query: opts.query, per_page: String(opts.per_page) });
    if (opts.orientation) params.set("orientation", opts.orientation);
    if (opts.color) params.set("color", opts.color);

    const res = await fetch(`${BASE_URL}/search?${params}`, { headers: { Authorization: this.apiKey } });
    if (!res.ok) throw new Error(`Pexels ${res.status}`);
    const data = await res.json() as any;

    return data.photos.map((p: any) => ({
      id: String(p.id), source: "pexels" as const,
      thumbnail_url: p.src.medium, full_url: p.src.original, download_url: p.src.original,
      width: p.width, height: p.height,
      description: p.alt || "", photographer: p.photographer, license: "Pexels License (free)",
    }));
  }

  async getDownloadUrl(id: string) {
    const res = await fetch(`${BASE_URL}/photos/${id}`, { headers: { Authorization: this.apiKey } });
    const data = await res.json() as any;
    return { url: data.src.original, photographer: data.photographer };
  }
}
```

---

## 14. Provider: Pixabay 클라이언트

파일: `src/providers/pixabay.ts`

```typescript
import type { StockSearchResult } from "../tools/stock-search.js";
const BASE_URL = "https://pixabay.com/api";

export class PixabayClient {
  private apiKey: string;
  constructor() {
    this.apiKey = process.env.PIXABAY_API_KEY || "";
    if (!this.apiKey) throw new Error("PIXABAY_API_KEY 미설정");
  }

  async search(opts: { query: string; orientation?: string; category?: string; min_width?: number; per_page: number }): Promise<StockSearchResult[]> {
    const params = new URLSearchParams({ key: this.apiKey, q: opts.query, per_page: String(opts.per_page), image_type: "photo" });
    if (opts.orientation && opts.orientation !== "squarish")
      params.set("orientation", opts.orientation === "landscape" ? "horizontal" : "vertical");
    if (opts.category) params.set("category", opts.category);
    if (opts.min_width) params.set("min_width", String(opts.min_width));

    const res = await fetch(`${BASE_URL}/?${params}`);
    if (!res.ok) throw new Error(`Pixabay ${res.status}`);
    const data = await res.json() as any;

    return data.hits.map((p: any) => ({
      id: String(p.id), source: "pixabay" as const,
      thumbnail_url: p.webformatURL, full_url: p.largeImageURL, download_url: p.largeImageURL,
      width: p.imageWidth, height: p.imageHeight,
      description: p.tags || "", photographer: p.user, license: "Pixabay License (free)",
    }));
  }

  async getDownloadUrl(id: string) {
    const params = new URLSearchParams({ key: this.apiKey, id });
    const res = await fetch(`${BASE_URL}/?${params}`);
    const data = await res.json() as any;
    return { url: data.hits[0].largeImageURL, photographer: data.hits[0].user };
  }
}
```

---

## 15. 유틸: 파일 관리자

파일: `src/utils/file-manager.ts`

```typescript
import fs from "fs";
import path from "path";
import { execSync } from "child_process";

const ASSETS_ROOT = process.env.ASSETS_DIR || path.join(process.cwd(), "assets");
const DIRS = {
  generated: path.join(ASSETS_ROOT, "generated"),
  stock: path.join(ASSETS_ROOT, "stock"),
  processed: path.join(ASSETS_ROOT, "processed"),
};
Object.values(DIRS).forEach((dir) => {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
});

export async function saveGeneratedImage(base64: string, format: string, baseName: string): Promise<string> {
  const filepath = path.join(DIRS.generated, `${baseName}.${format}`);
  fs.writeFileSync(filepath, Buffer.from(base64, "base64"));
  return filepath;
}

export async function downloadAndSave(url: string, baseName: string): Promise<string> {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`다운로드 실패: ${response.status}`);
  const contentType = response.headers.get("content-type") || "";
  const ext = contentType.includes("png") ? "png" : contentType.includes("webp") ? "webp" : "jpg";
  const filepath = path.join(DIRS.stock, `${baseName}.${ext}`);
  fs.writeFileSync(filepath, Buffer.from(await response.arrayBuffer()));
  return filepath;
}

export async function resizeImage(
  inputPath: string,
  opts: { width?: number; height?: number; format?: string; quality?: number }
): Promise<string> {
  const ext = opts.format || path.extname(inputPath).slice(1) || "jpg";
  const outputPath = path.join(DIRS.processed,
    `${path.basename(inputPath, path.extname(inputPath))}_resized.${ext}`);
  const size = opts.width && opts.height ? `${opts.width}x${opts.height}!`
    : opts.width ? `${opts.width}x` : `x${opts.height}`;
  const q = opts.quality ? `-quality ${opts.quality}` : "";
  execSync(`convert "${inputPath}" -resize ${size} ${q} "${outputPath}"`);
  return outputPath;
}

export interface AssetInfo {
  path: string; filename: string; category: string;
  size: number; dimensions?: { width: number; height: number }; created: string;
}

export async function listAssets(category: string, sortBy: string): Promise<AssetInfo[]> {
  const dirs = category === "all" ? Object.entries(DIRS) : [[category, DIRS[category as keyof typeof DIRS]]];
  const assets: AssetInfo[] = [];
  for (const [cat, dir] of dirs) {
    if (!dir || !fs.existsSync(dir as string)) continue;
    for (const file of fs.readdirSync(dir as string)) {
      const filepath = path.join(dir as string, file);
      const stat = fs.statSync(filepath);
      if (stat.isFile()) assets.push({
        path: filepath, filename: file, category: cat as string,
        size: stat.size, created: stat.birthtime.toISOString(),
      });
    }
  }
  switch (sortBy) {
    case "date": assets.sort((a, b) => b.created.localeCompare(a.created)); break;
    case "name": assets.sort((a, b) => a.filename.localeCompare(b.filename)); break;
    case "size": assets.sort((a, b) => b.size - a.size); break;
  }
  return assets;
}

export async function cleanupAssets(opts: {
  olderThanHours: number; category: string; dryRun: boolean;
}): Promise<{ count: number; totalSize: number }> {
  const cutoff = Date.now() - opts.olderThanHours * 3600000;
  const dirs = opts.category === "all" ? Object.values(DIRS) : [DIRS[opts.category as keyof typeof DIRS]];
  let count = 0, totalSize = 0;
  for (const dir of dirs) {
    if (!dir || !fs.existsSync(dir)) continue;
    for (const file of fs.readdirSync(dir)) {
      const filepath = path.join(dir, file);
      const stat = fs.statSync(filepath);
      if (stat.isFile() && stat.mtimeMs < cutoff) {
        totalSize += stat.size; count++;
        if (!opts.dryRun) fs.unlinkSync(filepath);
      }
    }
  }
  return { count, totalSize };
}
```

---

## 16. package.json & tsconfig.json

### package.json

```json
{
  "name": "mcp-design-assets",
  "version": "1.0.0",
  "description": "AI 이미지 생성 + 스톡이미지 + ComfyUI 통합 MCP 서버",
  "type": "module",
  "main": "dist/index.js",
  "bin": { "mcp-design-assets": "dist/index.js" },
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "start:sse": "node dist/index.js --sse --port 3100",
    "dev": "tsx src/index.ts",
    "dev:sse": "tsx src/index.ts --sse --port 3100"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.12.0",
    "dotenv": "^16.4.0",
    "ws": "^8.16.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/ws": "^8.5.0",
    "tsx": "^4.7.0",
    "typescript": "^5.4.0"
  }
}
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "node",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

---

## 17. 설치 & 연동 가이드

### 설치

```bash
cd mcp-design-assets
npm install
cp .env.example .env    # API 키 채우기
npm run build           # dist/ 폴더 생성
```

### 클로드코드 (안티그래비티) 연결

```bash
claude mcp add design-assets -- node /path/to/mcp-design-assets/dist/index.js
```

또는 `.claude/mcp.json`:

```json
{
  "mcpServers": {
    "design-assets": {
      "command": "node",
      "args": ["/path/to/mcp-design-assets/dist/index.js"],
      "env": {
        "NANOBANA_API_KEY": "...",
        "UNSPLASH_ACCESS_KEY": "...",
        "PEXELS_API_KEY": "...",
        "PIXABAY_API_KEY": "..."
      }
    }
  }
}
```

### 클로드 데스크탑 앱 / 코워크 연결

`claude_desktop_config.json`에 추가:

```json
{
  "mcpServers": {
    "design-assets": {
      "command": "node",
      "args": ["C:/Users/desig/path/to/mcp-design-assets/dist/index.js"]
    }
  }
}
```

---

## 18. 사용 시나리오

### PPT 배경 이미지 생성

```
"해양 테마 배경 만들어줘 1920x1080"
→ generate_image(prompt: "maritime sunset, golden light", width: 1920, height: 1080, style: "photorealistic")
→ /assets/generated/nanobana_xxx.png → slide.addImage({ path })
```

### 스톡 이미지 검색 → 다운로드

```
"부산항 야경 사진 찾아줘"
→ stock_search(query: "busan port night", orientation: "landscape")
→ 결과 목록 → stock_download(download_id: "unsplash:abc123", resize_width: 1920)
```

### ComfyUI 스타일 변환

```
"이 사진을 수채화 스타일로 변환"
→ comfyui_run(workflow: "img2img", input_image: "...", denoise_strength: 0.6)
```

### ComfyUI 업스케일 / 배경 제거

```
"해상도 높여줘" → comfyui_run(workflow: "upscale", input_image: "...")
"배경 제거해줘" → comfyui_run(workflow: "remove-bg", input_image: "...")
```

---

## 19. TODO: 커스터마이징 포인트

| 위치 | 설명 |
|------|------|
| `providers/nanobana.ts` L37-57 | 나노바나나2 실제 API 엔드포인트, 요청 형식, 응답 매핑 |
| `providers/nanobana.ts` L68-74 | 응답 JSON에서 이미지 데이터 추출 경로 |
| `providers/comfyui.ts` buildImg2Img | img2img 워크플로 노드 값 주입 로직 |
| `workflows/*.json` | ComfyUI 웹 UI에서 "Save (API Format)"으로 내보낸 JSON 배치 |
| `tools/generate-image.ts` model enum | 나노바나나2 모델 목록에 맞게 수정 |
| `tools/generate-image.ts` presets | 스타일 프리셋 프롬프트 커스텀 |
| `tools/comfyui-run.ts` workflow enum | 커스텀 워크플로 추가 시 enum 확장 |
| `utils/file-manager.ts` resizeImage | ImageMagick 대신 sharp 사용하려면 주석 해제 |

### 확장 아이디어

- Midjourney API 연동 (`providers/midjourney.ts`)
- SVG 아이콘 생성 (Iconify API)
- 이미지 메타데이터 분석 (EXIF, 색상 팔레트 추출)
- PPT 템플릿 에셋 캐싱
- AI 이미지 편집 (inpainting/outpainting 워크플로)
