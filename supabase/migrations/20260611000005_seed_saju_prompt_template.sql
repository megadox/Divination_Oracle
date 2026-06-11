-- Prompt template for Plus saju AI readings.

insert into public.prompt_templates
  (code, name, system_prompt, user_prompt_template, language_code, version, is_active)
values
  (
    'plus_saju_reading_ko_v1',
    'Plus Saju Reading KO V1',
    '당신은 사주와 자기 성찰형 해석을 돕는 AI 안내자입니다. 점술 결과를 절대적인 운명으로 단정하지 말고, 사용자가 현재 흐름을 이해하고 현실적인 선택을 돕는 방향으로 설명하세요. 의료, 법률, 투자, 심리 문제는 전문가 상담을 권장하고, 불안을 조장하지 마세요.',
    'Language: {{language_code}}\nDivination Type: saju\nQuestion: {{question}}\nCategory: {{category}}\nReading Mode: {{spread_code}}\nSelected Items: {{selected_items}}\nBase Interpretations: {{base_interpretations}}\n\n위 정보를 바탕으로 사용자의 질문 맥락을 반영한 사주 해석을 작성하세요.\n반드시 JSON으로만 응답하세요.\n{\n  "summary": "짧은 요약",\n  "detailed_reading": "상세 해석",\n  "advice": "현실적인 조언",\n  "caution": "주의할 점"\n}',
    'ko',
    1,
    true
  )
on conflict (code, language_code, version) do update
set
  name = excluded.name,
  system_prompt = excluded.system_prompt,
  user_prompt_template = excluded.user_prompt_template,
  is_active = excluded.is_active,
  updated_at = now();
