# kafka 3.6.2 자동 설치 및 설정 setup 앤서블

## 필수 준비

- **필수 셋팅**: `system_download.txt 파일 /data/work 하위에 위치 필수!!!!`

## 참조 파일

- **셋업 참조 파일**: `system_download.txt(/data/work 하위에 위치 필수!!!!)`
- **전체 파이프라인 플레이북**: `kafka_deploy.yml`

## 각 파일 설명

1. **`hosts.ini`** : 인벤토리(관리 대상 시스템 리스트)
2. **`main.yml`** : play_book 변수를 담은 파일
3. **`tar_scp.sh`** : kafka 각 서버에 tar파일 생성
5. **`entrypoint.sh`** : kafka 초기 설정 동적 setup 및 각 kafka 서버 배포하는 스크립트
6. **`kafka_deploy.yml`** : 앤서블 플레이북

## 실행 방법

1. `kafka_deploy.yml` 플레이북을 실행하여 전체 파이프라인을 시작합니다.
   ```sh
   ansible-playbook -i /data/work/kafka_3.6.2_auto_ansible/hosts.ini /data/work/kafka_3.6.2_auto_ansible/kafka_deploy.yml
   ```

## ansible 플레이북 구조

- `Create Kafka_tar directory`: 각 kafka 서버에 기본 kafka 디렉토리, tar 저장할 디렉토리 생성
- `Copy Kafka_tar to servers`: tar_scp.sh 스크립트를 실행하여 Kafka tar 파일 각 서버 tar 저장 디렉토리에 복사
- `Extract kafka_tar`: 각 서버 kafka tar파일 압축 해제
- `entrypoint_sh start`: entrypoint.sh 스크립트를 실행하여 각 서버 kafka 설정 동적 setup 및 setup된 설정 파일 각 kafka 서버 배포

---

이 플레이북은 kafka 클러스터를 자동으로 설정하고 Start 하는 과정을 자동화 합니다.

