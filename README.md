# DesignFlow

**DesignFlow** é um aplicativo Flutter para organização e controle de projetos de design, oferecendo gestão de etapas, clientes, pagamentos, checklists inteligentes e até frases motivacionais diárias para inspirar seu dia.

---

## Descrição do Aplicativo

- **Organização de Projetos** por status: A iniciar, Em andamento e Finalizados.
- **Checklists Inteligentes** para início e execução de cada projeto.
- **Controle de Pagamentos**: inclusive com opção de pagamento dividido via Pix (com controle visual).
- **Gerenciamento de Clientes** e tipos de serviço personalizados.
- **Dose de Inspiração**: frases motivacionais diárias consumidas de API gratuita.
- **Interface Responsiva e Moderna**: experiência otimizada para dispositivos móveis Android.

---

## Instruções de Instalação

### 1.Pré-requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) instalado (versão estável)
- Dispositivo Android ou emulador
- (Opcional) Android Studio ou VS Code

---

### 2.Clone o Projeto

```
git clone https://github.com/seuusuario/designflow.git
cd designflow
```

---

### 3.Instale as Dependências

``flutter pub get``

---

### 4.Configurações do Firebase

- 1.Acesse o Firebase Console
- 2.Crie um projeto e habilite Authentication (por e-mail/senha)
- 3.Baixe o arquivo google-services.json e coloque em android/app

---

### 5.Permissão de Internet

- Já está configurado no projeto em android/app/src/main/AndroidManifest.xml:
``<uses-permission android:name="android.permission.INTERNET"/>``

---

## Execução

- Conecte seu celular Android (com Depuração USB ativada) ou abra um emulador.
- Rode o comando:
``flutter run``

---

## Gerar APK

- Para instalar em qualquer celular Android:
``flutter build apk --release``

- O arquivo será gerado em:
``build/app/outputs/flutter-apk/app-release.apk``

- Basta copiar para o seu celular e instalar normalmente.

---

## Funcionalidades em Destaque

- Organização de projetos por status
- Checklists inteligentes por etapa
- Controle de pagamentos (Pix parcelado ou à vista)
- Gerenciamento de clientes e tipos de serviço
- Frases motivacionais diárias (Doses de Inspiração)
- Interface moderna e intuitiva

---