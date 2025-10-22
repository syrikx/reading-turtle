import boto3

# Polly 클라이언트 생성
polly = boto3.client("polly")

#text = "noun. a person engaged in or trained for spaceflight."

text = """
<speak>
  <prosody rate="80%">
    a person engaged in or trained for spaceflight
  </prosody>
</speak>
"""

# 요청
response = polly.synthesize_speech(
    Text=text,
    TextType="ssml",
    OutputFormat="mp3",          # 또는 'ogg_vorbis', 'pcm'
    VoiceId="Ivy",            # 미국식 여성 음성 (Neural)
    Engine="neural"              # <-- 중요: Neural 음성 사용
)

# 결과 저장
with open("Ivy2.mp3", "wb") as f:
    f.write(response["AudioStream"].read())

print("✅ 음성 파일이 'output.mp3'로 저장되었습니다.")
