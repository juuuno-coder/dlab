namespace :limen do
  desc "Import TOP6 biddings from markdown"
  task import_biddings: :environment do
    puts "🚀 Importing TOP6 Limen biddings..."

    biddings_data = [
      {
        title: "부산관광 종합정보체계 구축 용역",
        agency: "부산시 관광정책과 / 부산관광공사",
        budget: "5~10억원",
        application_period: "상시",
        status: "예정",
        progress: 0,
        partner: "리멘(Limen)",
        description: "부산시는 데이터 기반 스마트 관광환경 구축을 핵심 추진전략으로 설정하고 있으며, 관광객 데이터 수집·분석·활용을 위한 통합 정보시스템이 필요합니다. 관광 추천·예약·결제·피드백을 통합하는 디지털 플랫폼 구축이 목표입니다.\n\n💡 협업 제안: 바이버스의 AI 기술과 모바일 개발 경험을 활용해 국내 지자체 최초 '모바일 퍼스트 AI 관광 플랫폼'으로 차별화하고, 낮은 유지보수 비용으로 지속가능한 시스템 운영을 제안합니다.",
        deadline: nil
      },
      {
        title: "2026 사회공헌플랫폼 앱 운영 용역",
        agency: "부산시 청년정책과",
        budget: "2~5억원",
        application_period: "4월 예정",
        status: "예정",
        progress: 0,
        partner: "리멘(Limen)",
        description: "부산시 청년, 시민, 기업이 참여하는 사회공헌 활동을 통합 관리하는 모바일 앱 개발 및 연간 운영 용역입니다. 자원봉사·기부·재능나눔 등을 연결하는 플랫폼으로 1365 자원봉사포털과 유사한 부산 특화 버전이 될 것으로 예상됩니다.\n\n💡 협업 제안: Expo 기반 크로스플랫폼 개발로 초기 비용 절감하고, 바이버스·제평가는요? 앱 운영 경험을 바탕으로 안정적인 유지보수와 사용자 참여 유도 UX를 제공합니다.",
        deadline: Date.parse("2026-04-30")
      },
      {
        title: "2026 부산관광스타트업 아카데미 운영",
        agency: "부산관광기업지원센터",
        budget: "1~3억원",
        application_period: "상시",
        status: "예정",
        progress: 0,
        partner: "리멘(Limen)",
        description: "부산관광기업지원센터는 지역 관광스타트업 발굴·육성을 위해 창업발전소 교육과정을 매년 운영하고 있으며, 역량 강화 교육·컨설팅·투자 유치 지원을 제공합니다. 3개월 과정으로 창업 아이디어 발굴부터 사업화까지 실전 중심 커리큘럼이 특징입니다.\n\n💡 협업 제안: 실제 스타트업 운영자(레오)가 강사로 참여하여 AI 활용 창업 실습을 제공하고, 바이버스 시연을 통해 '기술로 창업하는 방법'을 생생하게 전달합니다.",
        deadline: nil
      },
      {
        title: "콘텐츠 제작 전문직 및 마케팅 연계 교육과정 운영 용역",
        agency: "한국콘텐츠진흥원 / 부산시",
        budget: "1~2억원",
        application_period: "4월 예정",
        status: "예정",
        progress: 0,
        partner: "리멘(Limen)",
        description: "한국콘텐츠진흥원(KOCCA) 2026년 지원사업에 따르면, 콘텐츠 제작·마케팅 인재 양성에 대규모 예산이 투입되며, 부산시도 영상·웹툰·XR 등 콘텐츠 산업 육성에 집중하고 있습니다. 3개월 과정으로 AI 도구 활용 실습, SNS 마케팅, 데이터 분석, 취업 연계까지 포함하는 통합 교육과정으로 예상됩니다.\n\n💡 협업 제안: Claude, Midjourney 등 AI 도구를 활용한 콘텐츠 제작 실습을 커리큘럼에 포함하여 'AI 시대 콘텐츠 제작자 양성'으로 차별화하고, 팬이지 사례로 실전 마케팅 교육을 제공합니다.",
        deadline: Date.parse("2026-04-30")
      },
      {
        title: "2026 부산관광 온라인 서포터즈 운영",
        agency: "부산관광공사",
        budget: "5천만~1억원",
        application_period: "상시",
        status: "예정",
        progress: 0,
        partner: "리멘(Limen)",
        description: "부산관광공사는 SNS를 통한 관광 홍보를 강화하고 있으며, 온라인 서포터즈는 부산 관광지·축제·맛집 등을 직접 체험하고 콘텐츠를 제작·공유하는 역할을 합니다. 서포터즈 모집·관리·활동 지원·성과 분석을 포함하는 연간 운영 용역입니다.\n\n💡 협업 제안: 팬이지 플랫폼을 서포터즈 전용 사이트로 제공하고, AI 콘텐츠 생성 도구로 서포터즈의 제작 부담을 줄이며, SNS 자동 배포 시스템으로 확산 효과를 극대화합니다.",
        deadline: nil
      },
      {
        title: "연말 결산 및 차기 연도 관광 마케팅 수립 용역",
        agency: "부산시 관광정책과",
        budget: "2~5억원",
        application_period: "10~11월",
        status: "예정",
        progress: 0,
        partner: "리멘(Limen)",
        description: "부산시는 매년 10~11월 차기 연도 관광 마케팅 전략을 수립하며, 2026년 데이터 분석을 바탕으로 2027년 목표·전략·예산을 기획하는 컨설팅 용역입니다. 관광객 빅데이터 분석, 트렌드 예측, 마케팅 믹스 전략, 실행계획 수립이 주요 업무입니다.\n\n💡 협업 제안: AI 기반 빅데이터 분석(검색어·SNS 트렌드·방문 패턴)으로 정량적 인사이트를 도출하고, 인터랙티브 웹 대시보드로 실시간 업데이트 가능한 '살아있는 전략 문서'를 제공합니다.",
        deadline: Date.parse("2026-11-30")
      }
    ]

    biddings_data.each_with_index do |data, index|
      bidding = Bidding.find_or_create_by(title: data[:title]) do |b|
        b.assign_attributes(data)
      end

      if bidding.persisted? && !bidding.previously_new_record?
        puts "  ✓ [#{index + 1}/6] 이미 존재: #{bidding.title}"
      else
        puts "  ✅ [#{index + 1}/6] 추가 완료: #{bidding.title}"
      end
    end

    puts "\n🎉 Import completed! Total: #{Bidding.count} biddings"
  end
end
