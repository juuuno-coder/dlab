/**
 * Pixabay API 클라이언트
 * https://pixabay.com/api/docs/
 * 무료: 100 req/minute
 */
import type { StockSearchResult } from "../tools/stock-search.js";

const BASE_URL = "https://pixabay.com/api";

export class PixabayClient {
  private apiKey: string;

  constructor() {
    this.apiKey = process.env.PIXABAY_API_KEY || "";
    if (!this.apiKey) throw new Error("PIXABAY_API_KEY 환경변수가 설정되지 않았습니다.");
  }

  async search(opts: {
    query: string;
    orientation?: string;
    category?: string;
    min_width?: number;
    per_page: number;
  }): Promise<StockSearchResult[]> {
    const params = new URLSearchParams({
      key: this.apiKey,
      q: opts.query,
      per_page: String(opts.per_page),
      image_type: "photo",
    });
    if (opts.orientation && opts.orientation !== "squarish") {
      params.set("orientation", opts.orientation === "landscape" ? "horizontal" : "vertical");
    }
    if (opts.category) params.set("category", opts.category);
    if (opts.min_width) params.set("min_width", String(opts.min_width));

    const res = await fetch(`${BASE_URL}/?${params}`);

    if (!res.ok) throw new Error(`Pixabay API ${res.status}: ${await res.text()}`);
    const data = await res.json() as any;

    return data.hits.map((photo: any) => ({
      id: String(photo.id),
      source: "pixabay" as const,
      thumbnail_url: photo.webformatURL,
      full_url: photo.largeImageURL,
      download_url: photo.largeImageURL,
      width: photo.imageWidth,
      height: photo.imageHeight,
      description: photo.tags || "",
      photographer: photo.user,
      license: "Pixabay License (free)",
    }));
  }

  async getDownloadUrl(id: string) {
    const params = new URLSearchParams({ key: this.apiKey, id });
    const res = await fetch(`${BASE_URL}/?${params}`);
    const data = await res.json() as any;
    const photo = data.hits[0];
    return { url: photo.largeImageURL, photographer: photo.user };
  }
}
