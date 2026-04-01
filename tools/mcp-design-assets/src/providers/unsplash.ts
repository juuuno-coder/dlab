/**
 * Unsplash API 클라이언트
 * https://unsplash.com/documentation
 * 무료 플랜: 50 req/hour
 */
import type { StockSearchResult } from "../tools/stock-search.js";

const BASE_URL = "https://api.unsplash.com";

export class UnsplashClient {
  private accessKey: string;

  constructor() {
    this.accessKey = process.env.UNSPLASH_ACCESS_KEY || "";
    if (!this.accessKey) throw new Error("UNSPLASH_ACCESS_KEY 환경변수가 설정되지 않았습니다.");
  }

  async search(opts: {
    query: string;
    orientation?: string;
    color?: string;
    per_page: number;
  }): Promise<StockSearchResult[]> {
    const params = new URLSearchParams({
      query: opts.query,
      per_page: String(opts.per_page),
    });
    if (opts.orientation) params.set("orientation", opts.orientation);
    if (opts.color) params.set("color", opts.color);

    const res = await fetch(`${BASE_URL}/search/photos?${params}`, {
      headers: { Authorization: `Client-ID ${this.accessKey}` },
    });

    if (!res.ok) throw new Error(`Unsplash API ${res.status}: ${await res.text()}`);
    const data = await res.json() as any;

    return data.results.map((photo: any) => ({
      id: photo.id,
      source: "unsplash" as const,
      thumbnail_url: photo.urls.small,
      full_url: photo.urls.full,
      download_url: photo.links.download,
      width: photo.width,
      height: photo.height,
      description: photo.description || photo.alt_description || "",
      photographer: photo.user.name,
      license: "Unsplash License",
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
    // Unsplash 가이드라인: 다운로드 시 트리거 API 호출 필수
    await fetch(`${BASE_URL}/photos/${id}/download`, {
      headers: { Authorization: `Client-ID ${this.accessKey}` },
    });
  }
}
