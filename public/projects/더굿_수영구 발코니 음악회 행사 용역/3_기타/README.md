# PPTX → Reveal.js HTML 변환 도구

간단한 사용법:

1. 의존성 설치

```bash
python -m pip install -r requirements.txt
```

2. 변환 실행

```bash
python tools/generate_slides.py "2_제안\2026 광안리 발코니 음악회 행사 용역 제안.pptx" output
```

3. 결과

- `output/reveal.html` — 브라우저로 열어 슬라이드 확인
- `output/assets/` — 추출된 이미지
- `output/content.json` — 슬라이드 원본 텍스트 및 이미지 목록

다음 단계 제안:

- 생성된 HTML을 바탕으로 디자인(타이포그래피, 색상)을 수정
- 필요 시 각 슬라이드를 PNG로 변환해 Figma에 임포트
