# D.US System Architecture & Business Value

본 문서는 디어스(D.US) 프로젝트의 기술적 차별성과 비즈니스 확장성을 다른 프로젝트에서 참고할 수 있도록 정리한 기술 백서입니다.

## 1. 계층형 멀티 테넌시 (Tiered Multi-tenancy)
상위 조직이 하위 조직을 지속적으로 생성하고 관리할 수 있는 **마이크로 에이전시 플랫폼** 구조입니다.

| 기능 | 상세 내용 | 비즈니스 가치 |
| :--- | :--- | :--- |
| **Recursive Parent-Child** | Agency 모델이 자신을 참조하여 부모-자식 관계 형성 | 프랜차이즈, 총판, 인플루언서 루프 구성 가능 |
| **Data Scoping** | Current User ➔ Agency ➔ (Sub-Agencies) ➔ Assets | 데이터 보안 및 독립성 유지 |
| **Role Evolution** | User ➔ Owner ➔ Master | 사용자 활동에 따른 자연스러운 권한 상승 유도 |

## 2. 결제-생성 자동화 파이프라인 (Order-to-Agency Pipeline)
기술적 지식이 없는 사용자도 결제 한 번으로 본인만의 웹 플랫폼을 소유하게 되는 자동화 로직입니다.

- **Trigger**: `Order.complete_payment!`
- **Action**:
    1. 고유 서브도메인(`site-XXXX`) 할당 및 Agency 레코드 자동 생성
    2. 사용자 `Role`을 `owner`로 즉시 업데이트
    3. 상위 에이전시(`Parent`) 자동 연결을 통한 수수료 체계 편입
    4. 관리자 대시보드 접근 권한 실시간 해제

## 3. 서브도메인 컨텍스트 엔진 (Subdomain Detection)
접속 주소에 따라 시스템의 동작과 데이터 소유권을 결정하는 지능형 라우팅입니다.

```ruby
# ApplicationController logic
def set_current_agency
  subdomain = request.subdomain
  if subdomain.present? && subdomain != "www"
    @current_agency = Agency.find_by(subdomain: subdomain)
  end
end
```
- **효과**: 별도의 로그인 선택 과정 없이, 유입 경로만으로 '누구의 사이트인가'를 명확히 정의합니다.

## 4. 프리미엄 디자인 언어 (Design System)
라이브러리에 의존하지 않는 순수 Vanilla CSS와 현대적 기술의 조합입니다.

- **Rich Effects**: `backdrop-filter`, `mask-image`, `css-variables`를 적극 활용한 고급 UI
- **Live Preview System**: Iframe 기반의 PC/Mobile 반응형 대모 미리보기 기능 (모든 템플릿에 적용)
- **Fast Performance**: 외부 JS 의존성을 최소화하여 Google PageSpeed Insight 최적화 대응

## 5. 비즈니스 확장 가능성 (Extensibility)
- **수수료 정산(`Commission`)**: 에이전시별 설정된 정산율 기반 자동 정산 시스템 추가 가능
- **커스텀 도메인**: 서브도메인을 넘어 개별 고객의 독립 도메인 연결 브릿지 확장 가능
- **메시징 자동화**: 상담 문의 시 상급 관리자와 하급 관리자에게 동시 알림 발송 로직 포함

---
*본 프로젝트는 단순한 코드의 집합이 아니라, **'플랫폼 위의 플랫폼'**을 지향하는 아키텍처를 담고 있습니다.*
