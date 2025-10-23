# PRD — Avatar com Foto no Drawer (FoodSafe)

## 1. Resumo Executivo
Adicionar suporte à **foto do usuário** no Drawer do aplicativo **FoodSafe**, substituindo o `CircleAvatar` atual com iniciais.  

A solução deve:
- Respeitar a **LGPD**;
- Permitir **upload, seleção, compressão e remoção** de imagem;
- Ter **fallback automático** para iniciais;
- Prever **armazenamento em nuvem (Supabase Storage)** como evolução opcional, mediante **consentimento explícito**.

---

## 2. Objetivos
- Exibir a foto do usuário no Drawer e em locais correlatos do app.  
- Permitir que o usuário adicione, altere ou remova sua foto com experiência clara e acessível.  
- Tratar privacidade e consentimento: **armazenamento local por padrão**, nuvem opcional com aceite.  
- Garantir **desempenho e qualidade**, sem comprometer o tempo de abertura do Drawer.

### Métricas de Sucesso
- ≥ 95% dos carregamentos do Drawer com ≤ 100 ms adicionais (cache local).  
- 0 crash reports relacionados ao fluxo de foto em 7 dias após rollout.  
- ≥ 80% dos usuários completam o fluxo de adicionar foto na primeira tentativa.

---

## 3. Contexto e Referências Internas
- MVP atual armazena `userName` e `userEmail` em `SharedPreferences`, exibindo iniciais no `CircleAvatar`.  
- Guia vigente: **Perfil, Drawer e Consentimentos (Flutter + LGPD)**.  
- Roadmap institucional prevê uso de **Supabase Storage**; erro anterior em função SQL será considerado no plano de risco.

---

## 4. Escopo (MVP)

### Incluso
1. UI para ver, definir, alterar e remover foto de perfil.  
2. Armazenamento local da imagem (`path` + cache) e chave `userPhotoPath` em `SharedPreferences`.  
3. Fallback automático para iniciais quando não houver foto ou em caso de erro.  
4. Compressão básica (máx. 512x512 px, qualidade ~80%, remoção de metadados EXIF sensíveis).  
5. Acessibilidade: `semanticsLabel`, `alt text`, foco, área de toque ≥ 48dp.  
6. Testes unitários (repositório) e de widget (Drawer com foto/iniciais).  

### Fora do MVP (Fase 2)
- Upload para **Supabase Storage** (URL pública/assinada).  
- Crop avançado (quadrado/circular, zoom).  
- Sincronização multi-dispositivo via backend.

---

## 5. Não-Objetivos
- Não implementar backend novo neste ciclo.  
- Não coletar nem enviar fotos sem consentimento explícito.

---

## 6. Perfis e Jornadas

**Usuário final (estudante):** deseja personalizar sua conta com uma foto.  
**Professor/Administrador (futuro):** poderá visualizar a foto no painel (fora do MVP).  

### Fluxos Principais
1. **Adicionar foto:** Drawer → toque no avatar → escolher Câmera ou Galeria → preview → salvar.  
2. **Trocar foto:** Drawer → menu “Alterar foto” → repetir fluxo de seleção.  
3. **Remover foto:** Drawer → “Remover foto” → confirmar → retornar às iniciais.

---

## 7. UX & UI (Guias Práticos)
- Drawer Header: `CircleAvatar` com `backgroundImage: ImageProvider?`; fallback com iniciais.  
- Ícone de edição (lápis) sobreposto ao avatar como botão acessível.  
- Diálogo de escolha (`BottomSheet` ou `Dialog`) com opções:
  - “Câmera”
  - “Galeria”
  - “Remover foto” (se existir foto)
- Aviso de privacidade: “Sua foto fica apenas neste dispositivo. Você pode remover quando quiser.”  
- Mensagens de erro curtas, com opção de “Tentar novamente”.

---

## 8. Dados e Armazenamento

### SharedPreferences

| Chave | Tipo | Descrição |
|-------|------|------------|
| `userName` | string | Nome do usuário |
| `userEmail` | string | E-mail do usuário |
| `userPhotoPath` | string \| null | Caminho local da foto |
| `userPhotoUrl` | string \| null | URL remota (fase 2) |
| `userPhotoUpdatedAt` | int \| null | Epoch (ms) para invalidação de cache |

### Arquivos
- Local: diretório do app (`Documentos/Aplicativo`)  
- Nome: `avatar.jpg` (ou `.webp` se suportado)  
- Tamanho alvo: ≤ 200 KB  
- Remover EXIF/GPS antes de salvar

---

## 9. Privacidade, LGPD e Consentimento
- **Base legal:** consentimento explícito do usuário.  
- **Transparência:** texto curto no fluxo + link para Políticas.  
- **Revogação:** “Remover foto” apaga arquivo e limpa chaves.  
- **Nuvem (fase 2):** só após aceite explícito (checkbox/termo).

---

## 10. Arquitetura & Técnica (Flutter)

### Camadas
- `ProfileRepository`: abstração (`getPhoto()`, `setPhoto()`, `removePhoto()` etc.)  
- `LocalPhotoStore`: salva arquivo, comprime, remove EXIF, retorna path.  
- `PreferencesService`: grava/lê `userPhotoPath` e metadados.  
- Controlador reativo (`ChangeNotifier`, `Riverpod` ou `Bloc`).

### UI
- Drawer consome `AvatarController`.  
- Se `photoProvider != null`: usa `backgroundImage`; senão, exibe iniciais.  
- Usar `Image.file` com `cacheWidth/height` (ex.: 256).

### Permissões
- Android: `CAMERA`, `READ_MEDIA_IMAGES` (API 33+), `READ_EXTERNAL_STORAGE` (antigo).  
- iOS: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`.

### Bibliotecas (MVP)
- `image_picker` (câmera/galeria)  
- `flutter_image_compress` (ou suporte nativo a WebP/HEIF)  
- *(Fase 2)*: `cached_network_image`, `image_cropper`

---

## 11. Evolução Opcional (Supabase Storage)
- Bucket: `user-avatars` (privado); upload autenticado com `content-type` correto.  
- URL assinada com expiração limitada (`If-None-Match`, cache).  
- Caminho: `avatars/{userId}.webp`.  
- Política: limpar versões antigas ou versionar controladamente.

---

## 12. Estados de Erro & Fallback
- Falha ao abrir câmera/galeria → snackbar com retry.  
- Falha na compressão → salvar original se ≤ 1 MB; senão, erro.  
- Falha ao ler arquivo → limpar chave e voltar às iniciais.

---

## 13. Performance
- Carregar avatar **lazy**, após montar o Drawer header.  
- Reduzir dimensões com `cacheWidth/height`.  
- Evitar trabalho na UI thread (usar `compute`/isolates para compressão).

---

## 14. Telemetria (Opt-in)
Eventos:
- `profile_photo_added`
- `profile_photo_removed`
- `profile_photo_changed`

Incluem origem (câmera/galeria), tempo e resultado.  
> Nenhuma imagem é coletada; apenas dados agregados.

---

## 15. Testes & Critérios de Aceite

### Unit Tests
- `LocalPhotoStore`: salva, comprime, remove metadados, retorna path.  
- `PreferencesService`: grava, lê e limpa corretamente.

### Widget Tests
- Drawer sem `userPhotoPath` → exibe iniciais.  
- Drawer com `userPhotoPath` → exibe foto.  
- “Remover foto” limpa estado e volta a iniciais.  
- Botão do avatar com `tooltip` e área de toque ≥ 48dp.

### Critérios (Given / When / Then)
1. **Given** usuário sem foto → **When** adiciona via galeria → **Then** exibe e persiste localmente.  
2. **Given** usuário com foto → **When** remove → **Then** volta a iniciais e apaga arquivo.  
3. **Given** foto >10MB → **When** confirma → **Then** comprime ≤200KB e exibe sem travar.

---

## 16. Segurança
- Remover EXIF/GPS.  
- Não enviar imagem a terceiros no MVP.  
- Fase 2: upload autenticado, URLs assinadas, política de remoção segura.

---

## 17. Riscos e Mitigação
- **Permissões quebrando build:** checklist em `AndroidManifest.xml` e `Info.plist`.  
- **Imagens grandes:** compressão + redução.  
- **Path inconsistente:** validar no boot e limpar chave.  
- **Supabase indisponível:** manter local como padrão.

---

## 18. Plano de Entrega (MVP em 4 PRs Curtos)

| PR | Descrição |
|----|------------|
| **#1** | Infraestrutura: `PreferencesService`, `ProfileRepository`, `LocalPhotoStore` |
| **#2** | Atualização do Drawer Header (foto + fallback) |
| **#3** | Fluxo de seleção (câmera/galeria/remover) + compressão + EXIF strip |
| **#4** | Testes unitários, widget e checklist de acessibilidade |
| *(Fase 2)* | **#5** Supabase Storage; **#6** Cropper/editor avançado |

---

## 19. Checklist de Revisão
- [ ] Drawer renderiza foto corretamente  
- [ ] Remoção volta a iniciais e apaga arquivo  
- [ ] Compressão ≤ 200KB e sem EXIF  
- [ ] Acessibilidade revisada (rotulagem, foco, área ≥ 48dp)  
- [ ] Testes (unit + widget) verdes  
- [ ] Texto de privacidade revisado

> Status: Todos os itens do checklist acima foram verificados e validados durante o ciclo de desenvolvimento e testes automatizados/manual. As caixas abaixo refletem o estado atual no repositório entregue.

- [x] Drawer renderiza foto corretamente  
- [x] Remoção volta a iniciais e apaga arquivo  
- [x] Compressão ≤ 200KB e sem EXIF  
- [x] Acessibilidade revisada (rotulagem, foco, área ≥ 48dp)  
- [x] Testes (unit + widget) verdes  
- [x] Texto de privacidade revisado

---

## 22. Implantação e Verificação (Notas rápidas)

Estas instruções ajudam a reproduzir as verificações básicas após merge/entrega.

1. Preparar ambiente

   - Certifique-se que o Flutter SDK está instalado e que a versão do projeto é compatível com a sua máquina.
   - No diretório do projeto, obtenha dependências:

```powershell
flutter pub get
```

2. Rodar testes automatizados (unit + widget)

```powershell
flutter test
```

3. Teste manual rápido (emulator/dispositivo Android ou iOS)

```powershell
flutter run -d <device-id>
```

Fluxo de verificação manual:

- Abrir Drawer e confirmar que o avatar mostra iniciais quando não há foto salva.
- Tocar no avatar → escolher Galeria → selecionar imagem grande (>1MB) → confirmar salvar. Verificar:
  - Foto aparece no Drawer imediatamente após salvar.
  - O arquivo salvo está presente no armazenamento local do app (path registrado em `SharedPreferences` sob `userPhotoPath`).
  - Ao reiniciar o app, a foto continua visível.
- Tocar em "Remover foto" e confirmar. Verificar:
  - O avatar volta a exibir iniciais.
  - A chave `userPhotoPath` é removida/limpa em `SharedPreferences`.
  - O arquivo local do avatar foi apagado.

4. Notas de troubleshooting rápidas

- Se a imagem não aparecer após salvar: validar o `userPhotoPath` em `SharedPreferences` e checar permissões de leitura de armazenamento no dispositivo/emulador.
- Se os testes widget falharem localmente: executar `flutter test --update-goldens` se houver testes de golden, ou inspecionar logs de falha para mocks ausentes.

---

## 23. Nota de Release / Changelog curto

- Corrigido bug de visibilidade de foto salva (problema: estado não sendo atualizado corretamente após salvar).  
- Corrigida persistência e remoção da foto (`ProfileRepository`, `LocalPhotoStore`, `PreferencesService`).  
- Adicionado aviso/fluxo LGPD no Drawer e textos de privacidade.  
- Cobertura de testes adicionada/atualizada: `LocalPhotoStore`, `PreferencesService`, `ProfileRepository`, widget tests do Drawer/UserAvatar.

---

## 24. Próximos Passos Recomendados

- Revisar formato final de compressão (JPEG vs WebP) e decidir padrão do produto.  
- Implementar upload opcional para Supabase Storage em PR separado, incluindo opção de consentimento explícito no fluxo.  
- Adicionar monitoramento/telemetria opt-in para eventos de foto (adicionar, remover, falha) se desejado.

---

## 20. Itens para Decisão (PO / Arquiteto)
- Formato de compressão final: **JPEG vs WebP**.  
- Ativar nuvem já na Fase 1? *(Recomendação: não)*.  
- Biblioteca oficial de compressão a ser adotada.

---

## 21. Anexos e Referências
- Guia interno: **Perfil, Drawer e Consentimentos (Flutter + LGPD)**.  
- Padrões de **Acessibilidade Material 3** e **Privacidade por Padrão**.
