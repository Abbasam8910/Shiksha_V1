import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/chat_message.dart';
import 'models/chat_session.dart';
import 'providers/chat_provider.dart';
import 'providers/download_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/model_download_screen.dart';

import 'dart:ffi';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Explicitly load native libraries on Android to avoid "not found" errors
  // Order matters: OpenMP -> GGML -> Llama
  if (Platform.isAndroid) {
    try {
      DynamicLibrary.open('libomp.so');
      DynamicLibrary.open('libggml-base.so');
      DynamicLibrary.open('libggml-cpu.so');
      DynamicLibrary.open('libggml.so');
      DynamicLibrary.open('libllama.so');
      print('✅ Native libraries loaded successfully');
    } catch (e) {
      print('❌ Error loading native libraries: $e');
    }
  }

  await Hive.initFlutter();

  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ChatSessionAdapter());

  final chatBox = await Hive.openBox<ChatSession>('chat_sessions');

  runApp(
    ProviderScope(
      overrides: [chatBoxProvider.overrideWithValue(chatBox)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Mobileshiksha',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A67E), // OpenAI-ish green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A67E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: Consumer(
        builder: (context, ref, _) {
          final downloadService = ref.watch(modelDownloadServiceProvider);

          return FutureBuilder<bool>(
            future: downloadService.isModelDownloaded(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // If model is downloaded, go directly to chat
              if (snapshot.data == true) {
                return const ChatScreen();
              }

              // Otherwise show onboarding
              return const OnboardingScreen();
            },
          );
        },
      ),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => const ChatScreen(),
        '/download': (context) => const ModelDownloadScreen(),
      },
    );
  }
}
