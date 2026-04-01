/**
 * 파일 관리 유틸리티
 * 이미지 저장, 리사이즈, 캐싱, 정리
 */
import fs from "fs";
import path from "path";
import { execSync } from "child_process";

// 에셋 저장 루트 (환경변수로 오버라이드 가능)
const ASSETS_ROOT = process.env.ASSETS_DIR || path.join(process.cwd(), "assets");

const DIRS = {
  generated: path.join(ASSETS_ROOT, "generated"),
  stock: path.join(ASSETS_ROOT, "stock"),
  processed: path.join(ASSETS_ROOT, "processed"),
};

// 디렉토리 자동 생성
Object.values(DIRS).forEach((dir) => {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
});

// ── 이미지 저장 ──
export async function saveGeneratedImage(
  base64: string,
  format: string,
  baseName: string
): Promise<string> {
  const filename = `${baseName}.${format}`;
  const filepath = path.join(DIRS.generated, filename);
  const buffer = Buffer.from(base64, "base64");
  fs.writeFileSync(filepath, buffer);
  return filepath;
}

// ── URL에서 다운로드 & 저장 ──
export async function downloadAndSave(url: string, baseName: string): Promise<string> {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`다운로드 실패: ${response.status}`);

  const contentType = response.headers.get("content-type") || "";
  const ext = contentType.includes("png") ? "png" :
              contentType.includes("webp") ? "webp" : "jpg";

  const filename = `${baseName}.${ext}`;
  const filepath = path.join(DIRS.stock, filename);
  const buffer = Buffer.from(await response.arrayBuffer());
  fs.writeFileSync(filepath, buffer);
  return filepath;
}

// ── 이미지 리사이즈 (ImageMagick 사용) ──
export async function resizeImage(
  inputPath: string,
  opts: { width?: number; height?: number; format?: string; quality?: number }
): Promise<string> {
  const ext = opts.format || path.extname(inputPath).slice(1) || "jpg";
  const outputFilename = `${path.basename(inputPath, path.extname(inputPath))}_resized.${ext}`;
  const outputPath = path.join(DIRS.processed, outputFilename);

  const size = opts.width && opts.height
    ? `${opts.width}x${opts.height}!`
    : opts.width
      ? `${opts.width}x`
      : `x${opts.height}`;

  const qualityFlag = opts.quality ? `-quality ${opts.quality}` : "";

  try {
    execSync(`convert "${inputPath}" -resize ${size} ${qualityFlag} "${outputPath}"`);
  } catch {
    // ImageMagick 없으면 sharp fallback 시도
    // const sharp = require("sharp");
    // await sharp(inputPath).resize(opts.width, opts.height).toFile(outputPath);
    throw new Error("ImageMagick(convert)이 설치되지 않았습니다. apt install imagemagick");
  }

  return outputPath;
}

// ── 에셋 목록 조회 ──
export interface AssetInfo {
  path: string;
  filename: string;
  category: string;
  size: number;
  dimensions?: { width: number; height: number };
  created: string;
}

export async function listAssets(
  category: string,
  sortBy: string
): Promise<AssetInfo[]> {
  const dirs = category === "all" ? Object.entries(DIRS) : [[category, DIRS[category as keyof typeof DIRS]]];
  const assets: AssetInfo[] = [];

  for (const [cat, dir] of dirs) {
    if (!dir || !fs.existsSync(dir as string)) continue;
    const files = fs.readdirSync(dir as string);

    for (const file of files) {
      const filepath = path.join(dir as string, file);
      const stat = fs.statSync(filepath);
      if (!stat.isFile()) continue;

      assets.push({
        path: filepath,
        filename: file,
        category: cat as string,
        size: stat.size,
        created: stat.birthtime.toISOString(),
      });
    }
  }

  // 정렬
  switch (sortBy) {
    case "date": assets.sort((a, b) => b.created.localeCompare(a.created)); break;
    case "name": assets.sort((a, b) => a.filename.localeCompare(b.filename)); break;
    case "size": assets.sort((a, b) => b.size - a.size); break;
  }

  return assets;
}

// ── 에셋 정리 ──
export async function cleanupAssets(opts: {
  olderThanHours: number;
  category: string;
  dryRun: boolean;
}): Promise<{ count: number; totalSize: number }> {
  const cutoff = Date.now() - opts.olderThanHours * 60 * 60 * 1000;
  const dirs = opts.category === "all" ? Object.values(DIRS) : [DIRS[opts.category as keyof typeof DIRS]];

  let count = 0;
  let totalSize = 0;

  for (const dir of dirs) {
    if (!dir || !fs.existsSync(dir)) continue;
    const files = fs.readdirSync(dir);

    for (const file of files) {
      const filepath = path.join(dir, file);
      const stat = fs.statSync(filepath);

      if (stat.isFile() && stat.mtimeMs < cutoff) {
        totalSize += stat.size;
        count++;
        if (!opts.dryRun) fs.unlinkSync(filepath);
      }
    }
  }

  return { count, totalSize };
}

export async function getAssetInfo(filepath: string): Promise<AssetInfo | null> {
  if (!fs.existsSync(filepath)) return null;
  const stat = fs.statSync(filepath);
  const category = filepath.includes("/generated/") ? "generated" :
                   filepath.includes("/stock/") ? "stock" : "processed";

  return {
    path: filepath,
    filename: path.basename(filepath),
    category,
    size: stat.size,
    created: stat.birthtime.toISOString(),
  };
}
