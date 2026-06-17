# AGENTS.md

## 프로젝트 개요
점술 서비스 앱. 무료 버전은 DB 기반 고정 해석, Plus 버전은 AI 개인화 해석 제공.

## 기술 구조
- Flutter
- Supabase
- OpenAI API
- RevenueCat

## 개발 규칙
- 기능 구현 전 간단한 설계 먼저 작성
- DB 변경 시 migration 파일 생성
- 무료 기능과 Plus 기능 분리
- AI API는 Plus 사용자에게만 호출