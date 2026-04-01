# 윈도우에서 WSL2(리눅스)로 완벽한 Rails 개발 환경 구축 가이드

이 문서는 윈도우의 한글 경로 문제를 근본적으로 해결하고, Rails 개발에 최적화된 리눅스(Ubuntu) 환경을 윈도우 안에 구축하는 방법을 단계별로 안내합니다.

## 1단계: WSL2 설치 (윈도우에서 진행)

1. **PowerShell을 관리자 권한**으로 실행합니다.
   - 윈도우 검색창(시작 버튼)에 `PowerShell` 검색 -> 마우스 우클릭 -> **'관리자 권한으로 실행'** 클릭.
2. 아래 명령어를 복사하여 붙여넣고 엔터(Enter)를 칩니다.
   ```powershell
   wsl --install
   ```
   _(이미 설치되어 있다는 메시지가 뜨면 `wsl --update`를 실행해보세요.)_
3. 설치가 완료되면 **컴퓨터를 재부팅**합니다. (필수)

---

## 2단계: Ubuntu 사용자 설정

1. 재부팅 후 자동으로 **Ubuntu** 터미널 창이 뜰 것입니다. (안 뜨면 시작 메뉴에서 `Ubuntu`를 찾아 실행)
2. 잠시 기다리면 `Enter new UNIX username:` 메시지가 뜹니다.
3. **영문 소문자**로 된 사용자 이름을 입력하고 엔터를 칩니다. (예: `dlab`, `dev`, `bori`)
   - **주의:** 절대 한글이나 공백을 넣지 마세요!
4. 비밀번호를 설정합니다. (입력할 때 화면에 아무것도 안 보이는 것은 정상입니다. 입력 후 엔터)

---

## 3단계: 필수 개발 도구 설치 (Ubuntu 터미널에서 진행)

이제 Ubuntu 터미널 창에서 아래 명령어들을 **한 줄씩 순서대로** 복사해서 실행하세요. 리눅스 비밀번호를 물어보면 입력하면 됩니다.

### 3-1. 패키지 목록 업데이트 및 기본 도구 설치

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev
```

### 3-2. rbenv (Ruby 버전 관리자) 설치

```bash
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

### 3-3. Ruby 및 Rails 설치 (시간이 조금 걸립니다)

```bash
rbenv install 3.2.0
rbenv global 3.2.0
gem install bundler
gem install rails
```

---

## 4단계: VS Code 연동 및 프로젝트 가져오기

### 4-1. VS Code 확장 설치

1. 윈도우에서 VS Code를 켭니다.
2. 왼쪽 확장(Extensions) 탭에서 `WSL`을 검색하여 설치합니다. (Microsoft 제작)

### 4-2. 프로젝트 폴더 생성 및 이동

다시 **Ubuntu 터미널**로 돌아와서 아래 명령어를 실행합니다.
(윈도우의 C드라이브 파일보다는 리눅스 내부 파일 시스템을 써야 속도가 훨씬 빠릅니다.)

```bash
# 홈 디렉토리로 이동
cd ~

# 프로젝트 폴더 생성
mkdir projects
cd projects

# 윈도우에 있던 프로젝트 복사해오기 (시간이 좀 걸릴 수 있습니다)
# 주의: 아래 경로는 현재 사용자명을 기준으로 작성되었습니다. 본인의 윈도우 사용자명으로 수정이 필요할 수 있습니다.
cp -r /mnt/c/projects/dlab-website .
```

### 4-3. WSL에서 VS Code 열기

```bash
cd dlab-website
code .
```

이제 VS Code가 새로 열리면서 좌측 하단에 `> WSL: Ubuntu`라고 표시될 것입니다. 이것이 성공입니다!

---

## 5단계: 프로젝트 의존성 설치 (새 VS Code 터미널에서)

방금 열린 VS Code의 터미널(Ctrl+`)을 열고 아래 명령어로 라이브러리를 설치합니다.

```bash
bundle install
yarn install
```

이제 `bin/dev` 또는 `rails s`를 입력하면 오류 없이 서버가 실행될 것입니다!
