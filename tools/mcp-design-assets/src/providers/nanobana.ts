/**
 * 나노바나나2 API 클라이언트
 * API 문서에 맞게 엔드포인트/파라미터를 조정하세요
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
  images: Array<{
    base64: string;
    seed: number;
  }>;
}

export class NanobanaClient {
  private apiKey: string;
  private baseUrl: string;

  constructor() {
    this.apiKey = process.env.NANOBANA_API_KEY || "";
    this.baseUrl = process.env.NANOBANA_API_URL || "https://api.nanobana2.example.com/v1";

    if (!this.apiKey) {
      throw new Error("NANOBANA_API_KEY 환경변수가 설정되지 않았습니다.");
    }
  }

  async generate(options: GenerateOptions): Promise<GenerateResult> {
    // ──────────────────────────────────────────────
    // TODO: 나노바나나2 실제 API 스펙에 맞게 수정
    // ──────────────────────────────────────────────
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
        // 나노바나나2 고유 파라미터 추가 가능
        // sampler: "euler_a",
        // scheduler: "normal",
      }),
    });

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`나노바나나2 API 오류 (${response.status}): ${err}`);
    }

    const data = await response.json() as any;

    // 응답 형식을 통일된 포맷으로 변환
    // TODO: 실제 응답 구조에 맞게 매핑 조정
    return {
      images: (data.images || data.results || []).map((img: any) => ({
        base64: img.base64 || img.b64_json || img.data,
        seed: img.seed || data.seed || 0,
      })),
    };
  }
}
