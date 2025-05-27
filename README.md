# Proyecto Final - Aplicación de Cursos con Flutter

### ***Hamilton Santiago Insandara Alvarez***
### *Electiva III*

## Descripción del Proyecto

Se trata de una aplicación mobile para la creación e inscripción de cursos Online, la aplciación permite a usuarios registrarse en uno de dos roles, en el rol de usuario se permite la inscripción y visualización de cursos, de sus secciones y sus materiales, así como visualizar una gráfica de progreso de curso y descargar el curso a base de datos local para su visualización, el rol de Admin permite la creación y administración de cursos, los cuales pueden contener multiples secciones y materiales, con estos ultimos permitiendo la subida de archivos en formato pdf

## Información Técnica

Información del entorno de flutter donde se ejecuta la aplicación

Tras clonar el repositorio ejecutar en la consola, en la carpeta raíz del proyecto.

```cmd
flutter pub get
```

### Versiones Relevantes

- Flutter: 3.29.3
- Dart: 3.7.2
- DevTools: 2.42.3
- NDK: 27.0.12077973
- flutter_web_auth_2: ^4.0.0-alpha.0
- SDK: 3.7.0

### Librerias Utilizadas

- cupertino_icons: ^1.0.8 &rarr; Libreria añadida por flutter
- get: ^4.7.2 &rarr; Libreria GetX para el manejo de estado global
- appwrite: ^15.0.1 &rarr; Libreria Appwrite para realizar la conexión con Appwrite
- file_picker: ^10.1.7 &rarr; Libreria File Picker que permite implementar la funcionalidad de seleccionar y subir un documento desde el dispositivo, utilizado para adjuntar documentos pdf como materiales al curso
- pie_chart: ^5.4.0 &rarr; Libreria Pie Chart que permite implementar un widgets para crear gráficos de pastel utilizado para la pantalla de progreso de curso
- url_launcher: ^6.3.1 &rarr; Libreria URL Launcher que permite abrir o interactuar con URLs desde la aplicación o realizar mapear acciones a la apertura de URL, utilizado para ver documentos de curso
- connectivity_plus: ^6.1.4 &rarr; Libreria Connectivity Plus, se utiliza para verificar la conexión a internet del dispositivo, permite asignar acciones a la aplicación ante falta de conexión
- hive: ^2.2.3 &rarr; Libreria Hive para el manejo de base de datos local desde la aplicación, se utiliza para la descarga de cursos
- hive_flutter: ^1.1.0 &rarr; Forma parte de Hive para flutter, también se encarga de base de datos local
- hive_generator: ^2.0.1 &rarr; Extensión de Hive para generar automáticamente los Type Adapters de las clases, esto se hace porque hive puede almacenar tipos primitivos, pero para objetos creados, requiere adaptarlos para convertirlos a un formato aceptable para Hive, se usa para el manejo de base de datos local (Parece ser nuevo pero no lo incluí en las diapositivas por ser parte de Hive que si vimos en clase)
- build_runner: ^2.4.15 &rarr; Se usa para generar archivos a través de código de dart, se usa en el manejo de base de datos local junto a Hive Generator
- path_provider: ^2.1.5 &rarr; Es una libreria para poder encontrar ubicaciones en un sistema de archivos, es utilizado por Hive
- flutter_dotenv: ^5.2.1 &rarr; Es una libreria que permite el uso de archivos .env, se usa para acceder a variables de entorno

### Credenciales de Appwrite

Pegar esto en un archivo .env en la raíz del proyecto

APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=67e47f2e00348f8e6c7c
APPWRITE_DATABASE_ID=67e4801100030243f1fa
APPWRITE_BUCKET_ID=68215e75002b36942a4a
COLLECTION_COURSES=680661ad000b25f4a2cb
COLLECTION_SECTIONS=68065e50003b2cc2c7c9
COLLECTION_MATERIALS=68065fe9000045205d3b
COLLECTION_USERS=68169008003b3fc8eb6e
COLLECTION_ENROLLMENTS=6816cac400126da19702

### Información Necesaria para el Funcionamiento

Para que la aplicación se ejecute dentro de un emulador de android se podría tener en cuenta lo siguiente.

Asegurarse que en raíz/android/app/build.gradle.kts el archivo especificado se vea así:

```Kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.final_project"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.final_project"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
```

Lo más importante es que NDK sea "27.0.12077973"

Debido a incomatibilidades entre Appwrite y una librería clave de Flutter, es necesario añadir esto al final del archivo pubspec.yaml

```yaml
dependency_overrides:
  flutter_web_auth_2: ^4.0.0-alpha.0
```

Para la carga de dotenv asegurarse de que en pubspec.yaml haya una sección así, si el proyecto es nuevo, solo suele haber uses-material-design: true añadir el assets: - .env de ser necesario

```yaml
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true
  assets:
    - .env
```

Probé la aplicación en un emulador con las siguientes características:

Properties
avd.ini.displayname              Pixel 8 API 36
avd.ini.encoding                 UTF-8
AvdId                            Pixel_8_API_36
disk.dataPartition.size          6G
fastboot.chosenSnapshotFile      
fastboot.forceChosenSnapshotBoot no
fastboot.forceColdBoot           no
fastboot.forceFastBoot           yes
hw.accelerometer                 yes
hw.arc                           false
hw.audioInput                    yes
hw.battery                       yes
hw.camera.back                   virtualscene
hw.camera.front                  emulated
hw.cpu.ncore                     4
hw.device.hash2                  MD5:90973dc6b682b7344df33a6250481866
hw.device.manufacturer           Google
hw.device.name                   pixel_8
hw.dPad                          no
hw.gps                           yes
hw.gpu.enabled                   yes
hw.gpu.mode                      auto
hw.initialOrientation            portrait
hw.keyboard                      yes
hw.lcd.density                   420
hw.lcd.height                    2400
hw.lcd.width                     1080
hw.mainKeys                      no
hw.ramSize                       7562
hw.sdCard                        yes
hw.sensors.orientation           yes
hw.sensors.proximity             yes
hw.trackBall                     no
image.androidVersion.api         36
image.sysdir.1                   system-images\android-36\google_apis_playstore\x86_64\
PlayStore.enabled                true
runtime.network.latency          none
runtime.network.speed            full
showDeviceFrame                  yes
skin.dynamic                     yes
tag.display                      Google Play
tag.displaynames                 Google Play
tag.id                           google_apis_playstore
tag.ids                          google_apis_playstore
vm.heapSize                      228
