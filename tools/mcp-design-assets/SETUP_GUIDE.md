# MCP Design Assets Server - 설정 & 연동 가이드

## 1. 설치

```bash
cd mcp-design-assets
npm install
cp .env.example .env
# .env 파일에 API 키 입력
npm run build
```

## 2. 클로드코드 (안티그래비티) 연동

```bash
# stdio 모드로 MCP 서버 등록
claude mcp add design-assets -- node /path/to/mcp-design-assets/dist/index.js
```

또는 프로젝트 `.claude/mcp.json`에 직접 추가:
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

## 3. 클로드 코워크 연동

코워크에서는 두 가지 방법:

### 방법 A: 로컬 stdio (같은 PC)
코워크 설정 → MCP 서버 추가 → 명령어:
```
node /path/to/mcp-design-assets/dist/index.js
```

### 방법 B: SSE 원격 (다른 PC에서 실행)
```bash
# 서버 시작
npm run start:sse
# → http://localhost:3100 에서 SSE 엔드포인트 활성화
```
코워크 설정 → MCP 서버 URL: `http://your-pc-ip:3100/sse`


## 4. 도구 목록 & 사용 예시

### generate_image (나노바나나2)
```
"해양 테마 일러스트 배경을 생성해줘. 1920x1080, 네이비+골드 색조"
→ generate_image 호출
→ 이미지 경로 반환
→ PptxGenJS: slide.addImage({ path: "..." })
```

### comfyui_run (ComfyUI)
```
"이 사진을 수채화 스타일로 변환해줘"
→ comfyui_run(workflow: "img2img", input_image: "...", denoise_strength: 0.6)

"이 이미지 해상도를 높여줘"
→ comfyui_run(workflow: "upscale", input_image: "...")

"배경을 제거해줘"
→ comfyui_run(workflow: "remove-bg", input_image: "...")
```

### stock_search → stock_download
```
"부산항 야경 사진 찾아줘"
→ stock_search(query: "busan port night", orientation: "landscape")
→ 결과 목록 반환 (unsplash:abc, pexels:123 ...)

"첫 번째 사진 다운로드해서 1920x1080으로 리사이즈"
→ stock_download(download_id: "unsplash:abc", resize_width: 1920, resize_height: 1080)
→ 로컬 파일 경로 반환
```

### asset_list / asset_cleanup
```
"지금까지 생성한 이미지 목록 보여줘"
→ asset_list(category: "all")

"24시간 지난 이미지 정리해줘"
→ asset_cleanup(older_than_hours: 24, dry_run: false)
```


## 5. PPT 워크플로 통합 예시

선원의 날 제안서 작업 시 이런 흐름이 됩니다:

```
사용자: "선원의 날 제안서 PPT 배경에 넣을 해양 이미지 만들어줘"

클로드:
  1) generate_image(prompt: "korean maritime port, golden sunset,
     cinematic", width: 1920, height: 1080, style: "photorealistic")
     → /assets/generated/nanobana_xxx.png

  2) stock_search(query: "ship anchor nautical", min_width: 1920)
     → unsplash:abc123, pexels:456...

  3) stock_download(download_id: "unsplash:abc123",
     resize_width: 1920, resize_height: 1080)
     → /assets/stock/stock_unsplash_abc123.jpg

  4) PptxGenJS 스크립트에서:
     slide.addImage({ path: "/assets/generated/nanobana_xxx.png",
                      x: 0, y: 0, w: 10, h: 5.625 });
```


## 6. ComfyUI 워크플로 커스텀

`src/workflows/` 폴더에 ComfyUI에서 내보낸 API 포맷 JSON을 넣으면 됩니다:

1. ComfyUI 웹 UI에서 워크플로 완성
2. "Save (API Format)" 클릭
3. JSON 파일을 `src/workflows/` 에 저장
4. `comfyui-run.ts`에 빌더 함수 추가
5. tool 스키마의 workflow enum에 항목 추가


## 7. 확장 아이디어

- **Midjourney API** 연동 (providers/midjourney.ts 추가)
- **SVG 아이콘 생성** (Iconify API 연동)
- **이미지 메타데이터 분석** (EXIF, 색상 팔레트 추출)
- **PPT 템플릿 에셋 관리** (자주 쓰는 배경/아이콘 캐싱)
- **AI 이미지 편집** (inpainting, outpainting 워크플로)
