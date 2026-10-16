#!/usr/bin/env bash
# openapi.yaml'dan Flutter uygulamasının kullandığı Dart istemcisini (lib/api-client-dart) üretir.
# Gerekenler: Docker (openapi-generator için, Java gerekmez) ve Flutter/Dart SDK.
set -euo pipefail

GENERATOR_IMAGE="openapitools/openapi-generator-cli:v7.25.0"

root="$(cd "$(dirname "$0")/../.." && pwd)"
out="lib/api-client-dart"

rm -rf "$root/$out/lib"

docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$root:/local" \
  "$GENERATOR_IMAGE" generate \
  -i /local/lib/api-spec/openapi.yaml \
  -g dart-dio \
  -o "/local/$out" \
  --global-property apiTests=false,modelTests=false,apiDocs=false,modelDocs=false \
  --additional-properties pubName=gurme_client,pubLibrary=gurme_client,pubDescription="Gurme API istemcisi",serializationLibrary=json_serializable

cd "$root/$out"
# Şablon Dart 3.5'i hedefliyor; güncel json_serializable 3.8 sözdizimi (null-aware elements) üretiyor.
sed -i.bak "s/sdk: '>=3.5.0 <4.0.0'/sdk: '>=3.8.0 <4.0.0'/" pubspec.yaml && rm pubspec.yaml.bak
grep -q "sdk: '>=3.8.0" pubspec.yaml || { echo "pubspec.yaml SDK kısıtı beklenen biçimde değil" >&2; exit 1; }
dart pub get
dart run build_runner build --delete-conflicting-outputs
dart format lib >/dev/null
