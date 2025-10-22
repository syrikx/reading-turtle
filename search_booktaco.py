import requests
import json
import csv
from datetime import datetime

# 세션 생성 및 쿠키 설정
session = requests.Session()
session.headers.update({
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
    'Accept': '*/*',
    'Content-Type': 'application/json'
})

# 쿠키 추가
session.cookies.set('PHPSESSID', '28a5c6beff555d07b3c3fa1101cb8537', domain='app.booktaco.com', path='/')
session.cookies.set('user_session_id', '68f0a0a6d9f17', domain='app.booktaco.com', path='/')

# 요청 URL 및 데이터
url = 'https://app.booktaco.com/search'
payload = {
    "query": "a",
    "type": ["title"],
    "filter": ["under_69_pages"],
    "limit": 50,
    "offset": 0,
    "infiniteScroll": True,
    "studentSearch": False
}

# POST 요청 전송
response = session.post(url, json=payload)

# 응답 상태 확인
print(f"Status Code: {response.status_code}")
print(f"Response Length: {len(response.text)} bytes")

# 타임스탬프 생성
timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

# 원본 응답을 항상 텍스트 파일로 저장
txt_filename = f'booktaco_response_{timestamp}.txt'
with open(txt_filename, 'w', encoding='utf-8') as f:
    f.write(f"Status Code: {response.status_code}\n")
    f.write(f"Headers: {dict(response.headers)}\n\n")
    f.write("Response Body:\n")
    f.write(response.text)
print(f"✓ Raw response saved to: {txt_filename}")

# HTML 태그 제거
cleaned_text = response.text.replace("<span class='search-word'>", "").replace("</span>", "")

# 정리된 응답도 저장
cleaned_filename = f'booktaco_response_cleaned_{timestamp}.txt'
with open(cleaned_filename, 'w', encoding='utf-8') as f:
    f.write(cleaned_text)
print(f"✓ Cleaned response saved to: {cleaned_filename}")

# JSON 응답 파싱 (정리된 텍스트 사용)
try:
    data = json.loads(cleaned_text)
    print(f"\nResponse Data Keys: {data.keys() if isinstance(data, dict) else 'Not a dict'}")

    # 결과를 CSV로 저장
    csv_filename = f'booktaco_search_results_{timestamp}.csv'

    # JSON 응답을 CSV로 변환
    if isinstance(data, list) and len(data) > 0:
        # 리스트 형태의 데이터 (책 목록)
        fieldnames = data[0].keys() if isinstance(data[0], dict) else ['data']

        with open(csv_filename, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()

            for item in data:
                if isinstance(item, dict):
                    writer.writerow(item)
                else:
                    writer.writerow({'data': item})

        print(f"\n✓ Results saved to: {csv_filename}")
        print(f"✓ Total records: {len(data)}")

        # JSON 파일로도 저장
        json_filename = f'booktaco_search_response_{timestamp}.json'
        with open(json_filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"✓ JSON saved to: {json_filename}")

    elif isinstance(data, dict):
        # 딕셔너리 형태인 경우 (중첩된 구조일 수 있음)
        results = data.get('results', data.get('data', data.get('books', data)))

        if isinstance(results, list) and len(results) > 0:
            fieldnames = results[0].keys() if isinstance(results[0], dict) else ['data']

            with open(csv_filename, 'w', newline='', encoding='utf-8') as csvfile:
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                writer.writeheader()

                for item in results:
                    if isinstance(item, dict):
                        writer.writerow(item)

            print(f"\n✓ Results saved to: {csv_filename}")
            print(f"✓ Total records: {len(results)}")

        # JSON 파일로 저장
        json_filename = f'booktaco_search_response_{timestamp}.json'
        with open(json_filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"✓ JSON saved to: {json_filename}")
    else:
        print("\nUnexpected data structure")

except json.JSONDecodeError:
    print("\nError: Response is not valid JSON")
    print(f"Response text: {response.text[:500]}")
except Exception as e:
    print(f"\nError: {e}")
