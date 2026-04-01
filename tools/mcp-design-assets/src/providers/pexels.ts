/**
 * Pexels API 클라이언트
 * https://www.pexels.com/api/documentation/
 * 무료: 200 req/hour
 */
import type { StockSearchResult } from "../tools/stock-search.js";

const BASE_URL = "https://api.pexels.com/v1";

export class PexelsClient {
  private apiKey: string;

  constructor() {
    this.apiKey = process.env.PEXELS_API_KEY || "";
    if (!this.apiKey) throw new Error("PEXELS_API_KEY 환경변수가 설정되지 않았습니다.");
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

    const res = await fetch(`${BASE_URL}/search?${params}`, {
      headers: { Authorization: this.apiKey },
    });

    if (!res.ok) throw new Error(`Pexels API ${res.status}: ${await res.text()}`);
    const data = await res.json() as any;

    return data.photos.map((photo: any) => ({
      id: String(photo.id),
      source: "pexels" as const,
      thumbnail_url: photo.src.medium,
      full_url: photo.src.original,
      download_url: photo.src.original,
      width: photo.width,
      height: photo.height,
      description: photo.alt || "",
      photographer: photo.photographer,
      license: "Pexels License (free)",
    }));
  }

  async getDownloadUrl(id: string) {
    const res = await fetch(`${BASE_URL}/photos/${id}`, {
      headers: { Authorization: this.apiKey },
    });
    const data = await res.json() as any;
    return { url: data.src.original, photographer: data.photographer };
  }
}
