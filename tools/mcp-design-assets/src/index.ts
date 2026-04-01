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
    // SSE 모드 (코워크 원격 연결용)
    const port = parseInt(args[args.indexOf("--port") + 1] || "3100");
    console.error(`[design-assets] SSE mode on port ${port}`);
    // SSE transport 구현은 @modelcontextprotocol/sdk 참조
    // const transport = new SSEServerTransport({ port });
    // await server.connect(transport);
  } else {
    // stdio 모드 (클로드코드 로컬 연결용)
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error("[design-assets] stdio mode started");
  }
}

main().catch(console.error);
