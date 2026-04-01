# MCP Design Assets Server - 프로젝트 구조

```
mcp-design-assets/
├── package.json
├── tsconfig.json
├── .env.example              # API 키 템플릿
├── .env                      # 실제 API 키 (gitignore)
│
├── src/
│   ├── index.ts              # MCP 서버 진입점 (stdio/SSE)
│   ├── server.ts             # MCP 서버 핵심 설정
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
│   │   ├── txt2img.json      # 텍스트→이미지
│   │   ├── img2img.json      # 이미지→이미지 (스타일 변환)
│   │   ├── upscale.json      # 업스케일
│   │   └── remove-bg.json    # 배경 제거
│   │
│   ├── utils/
│   │   ├── image-utils.ts    # 리사이즈, 포맷 변환, base64
│   │   ├── file-manager.ts   # 다운로드 경로 관리, 캐싱
│   │   └── logger.ts         # 로깅
│   │
│   └── types/
│       ├── tools.ts          # 도구 입출력 타입
│       └── providers.ts      # 프로바이더 응답 타입
│
├── assets/                   # 생성/다운로드된 이미지 저장소
│   ├── generated/            # AI 생성 이미지
│   ├── stock/                # 스톡 다운로드 이미지
│   └── processed/            # 후처리된 이미지
│
└── tests/
    ├── generate.test.ts
    ├── comfyui.test.ts
    └── stock.test.ts
```
