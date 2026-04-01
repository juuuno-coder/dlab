# 2026년 리멘 협력 입찰&공모사업 샘플 데이터

biddings_data = [
  {
    title: "2026년 AI 기반 디지털 전환 지원사업",
    agency: "중소벤처기업부",
    application_period: "2026-03-01 ~ 2026-03-31",
    budget: "5억원",
    status: "예정",
    progress: 0,
    담당자: "레오",
    description: "중소기업 AI 디지털 전환 컨설팅 및 솔루션 개발"
  },
  {
    title: "지역 스마트시티 플랫폼 구축사업",
    agency: "과학기술정보통신부",
    application_period: "2026-02-15 ~ 2026-03-15",
    budget: "10억원",
    status: "진행중",
    progress: 30,
    담당자: "레오",
    description: "스마트시티 통합 플랫폼 설계 및 개발"
  },
  {
    title: "AI 바우처 지원사업 (데이터 가공)",
    agency: "NIPA",
    application_period: "2026-01-10 ~ 2026-02-10",
    budget: "3억원",
    status: "제출완료",
    progress: 90,
    담당자: "레오",
    description: "AI 학습용 데이터 가공 및 검수 서비스"
  },
  {
    title: "공공데이터 활용 창업 지원사업",
    agency: "행정안전부",
    application_period: "2026-04-01 ~ 2026-04-30",
    budget: "2억원",
    status: "예정",
    progress: 10,
    담당자: "레오",
    description: "공공데이터 기반 서비스 개발 지원"
  },
  {
    title: "SW마에스트로 과정 운영 용역",
    agency: "과학기술정보통신부",
    application_period: "2026-05-01 ~ 2026-05-31",
    budget: "8억원",
    status: "예정",
    progress: 0,
    담당자: "리멘",
    description: "SW마에스트로 교육 프로그램 기획 및 운영"
  }
]

biddings_data.each do |data|
  Bidding.find_or_create_by!(title: data[:title]) do |bidding|
    bidding.agency = data[:agency]
    bidding.application_period = data[:application_period]
    bidding.budget = data[:budget]
    bidding.status = data[:status]
    bidding.progress = data[:progress]
    bidding.assignee = data[:담당자]
    bidding.description = data[:description]
  end
end

puts "✅ 입찰사업 #{biddings_data.length}개 생성 완료"
