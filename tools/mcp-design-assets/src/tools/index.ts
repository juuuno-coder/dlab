/**
 * 도구 등록 허브
 * 모든 MCP 도구를 한 곳에서 등록
 */
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
