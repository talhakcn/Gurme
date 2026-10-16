# gurme_client

Flutter uygulamasının (`artifacts/app`) kullandığı Dart API istemcisi.
`lib/api-spec/openapi.yaml` dosyasından `openapi-generator` (dart-dio, json_serializable) ile üretilir.

**Elle düzenlemeyin.** `openapi.yaml` değişince depo kökünden yeniden üretin:

```sh
pnpm --filter @workspace/api-spec run codegen:dart
# ya da doğrudan: lib/api-spec/codegen-dart.sh
```

Docker ve Flutter SDK gerekir. Üretilen `*.g.dart` dosyaları da depoya eklenir; uygulamanın ayrıca kod üretmesi gerekmez.
