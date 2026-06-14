# Global Divination Platform Knowledge Architecture

## 1. 목표

전 세계 다양한 점술(Tarot, Astrology, Saju, Rune, Omikuji 등)을 하나의 플랫폼에서 제공하는 서비스 구축.

단순 AI 질의응답 방식이 아닌,

```text
점술 계산 엔진
→ 구조화된 결과
→ 지식창고(RAG)
→ AI 해석
```

구조를 통해 전문 점술 서비스 수준의 품질을 제공한다.

---

# 2. 전체 아키텍처

```text
┌─────────────┐
│   사용자    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 점술 계산엔진 │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 구조화 결과 │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 지식창고(RAG)│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  AI 해석기  │
└─────────────┘
```

---

# 3. Tarot (타로)

## 카드 구성

* 메이저 아르카나 22장
* 마이너 아르카나 56장

총 78장

---

## 카드 정보 구조

```json
{
  "card":"The Fool",
  "number":"0",
  "arcana":"Major",
  "keywords":["시작","모험","순수"],
  "upright":"새로운 시작",
  "reversed":"무모함",
  "love":"...",
  "career":"...",
  "money":"...",
  "health":"..."
}
```

---

## 추가 지식

### 카드 조합

```text
The Fool + Magician
The Fool + Death
The Fool + Star
```

### 스프레드 해석

```text
3 Card Spread
Celtic Cross
Relationship Spread
Career Spread
```

---

# 4. Astrology (서양 점성술)

## 기본 별자리

```text
양자리
황소자리
쌍둥이자리
게자리
사자자리
처녀자리
천칭자리
전갈자리
사수자리
염소자리
물병자리
물고기자리
```

---

## 전문 서비스 구조

입력

```text
생년월일
출생시간
출생지
```

산출

```text
태양궁
달궁
상승궁

수성
금성
화성

12하우스

행성간 Aspect
```

---

## 추천 계산 엔진

Swiss Ephemeris

활용 목적

```text
천체 위치 계산
행성 위치 계산
하우스 계산
Aspect 계산
```

---

## 저장 데이터

```json
{
  "planet":"Venus",
  "sign":"Libra",
  "house":"7",
  "meaning":"관계 중심 성향"
}
```

---

# 5. Saju (사주)

## 입력 정보

```text
생년월일
출생시간
성별
```

---

## 계산 결과

```text
사주팔자

년주
월주
일주
시주

십성
오행
신강/신약
용신
희신

대운
세운
```

---

## 천간 DB

```json
{
  "name":"갑",
  "element":"목",
  "yinYang":"양",
  "meaning":"성장과 시작"
}
```

---

## 지지 DB

```json
{
  "name":"인",
  "element":"목",
  "animal":"호랑이"
}
```

---

## AI 역할

AI는 계산을 수행하지 않는다.

```text
계산엔진
→ 구조화 결과 생성

AI
→ 해석 담당
```

---

# 6. Rune (룬)

## Elder Futhark

24개 룬

```text
Fehu
Uruz
Thurisaz
Ansuz
Raidho
Kenaz
Gebo
Wunjo
...
```

---

## 저장 구조

```json
{
  "name":"Fehu",
  "upright":"풍요",
  "reversed":"손실",
  "love":"...",
  "career":"...",
  "money":"...",
  "spiritual":"..."
}
```

---

## 조합 해석

```text
Fehu + Raidho

Ansuz + Kenaz

Uruz + Gebo
```

---

# 7. Omikuji (오미쿠지)

## 등급

```text
대길
중길
소길
길
말길
흉
대흉
```

---

## 정보 구조

```json
{
  "fortune":"대길",
  "love":"최고의 인연",
  "business":"사업 확장 적기",
  "health":"건강 양호",
  "travel":"매우 좋음"
}
```

---

## 세부 카테고리

```text
연애
결혼
학업
취업
사업
건강
여행
분실물
```

---

# 8. 향후 확장 점술

## 중국

### 사주팔자

```text
BaZi
```

### 자미두수

```text
Zi Wei Dou Shu
```

---

## 일본

### 오미쿠지

### 혈액형 운세

---

## 서양

### Tarot

### Astrology

### Oracle Card

---

## 북유럽

### Rune

---

## 켈트

### Ogham

---

## 인도

### Vedic Astrology

---

## 아프리카

### Ifa Divination

---

# 9. 지식창고 구축 전략

## Level 1

기본 의미

```text
카드
룬
별자리
오행
```

---

## Level 2

상황별 의미

```text
연애
직업
재물
건강
인간관계
```

---

## Level 3

조합 의미

```text
카드 조합
룬 조합
오행 조합
행성 조합
```

---

## Level 4

전문 해석

```text
실제 상담 사례

전문가 해석

고전 문헌 기반 해석
```

---

# 10. AI 해석 방식

잘못된 방식

```text
사용자 질문

→ GPT
→ 답변
```

---

권장 방식

```text
사용자 질문

→ 점술 계산 엔진

→ 구조화 결과

→ 벡터 검색

→ 관련 지식 검색

→ GPT 해석

→ 사용자 응답
```

---

# 11. 서비스 우선순위

## Phase 1

```text
Tarot
Rune
Omikuji
```

목표

```text
빠른 서비스 런칭
```

---

## Phase 2

```text
Western Astrology
```

목표

```text
개인 맞춤형 운세
```

---

## Phase 3

```text
Saju
Zi Wei Dou Shu
```

목표

```text
동양 점술 확장
```

---

# 12. 최종 목표

전 세계 주요 점술을 하나의 플랫폼에서 제공하고,

각 점술별 계산 엔진과 전문 지식창고를 기반으로

AI가 전문가 수준의 맞춤형 해석을 제공하는 글로벌 점술 플랫폼을 구축한다.
