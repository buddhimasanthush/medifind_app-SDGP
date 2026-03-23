import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medifind_app/services/supabase_client.dart';
import 'dart:io';

void main() {
  test('test reminder insert', () async {
    await Supabase.initialize(
      url: 'https://zdgugonfvsadghkijfnh.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpkZ3Vnb25mdnNhZGdoa2lqZm5oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI0ODIyOTUsImV4cCI6MjA1ODA2NjI5NX0.n1D9Y6eQ19Bklq3rB6A7f9YfX2Gq7s8c6S4B9p6F8eY'
    );
    // login
    final res = await Supabase.instance.client.auth.signInWithPassword(
      email: 'qwert@gmail.com',
      password: '12341234'
    );
    print('Logged in user: ${res.user?.id}');

    try {
      final insertRes = await Supabase.instance.client.from('reminders').insert({
        'user_id': res.user!.id,
        'medicine_name': 'TestMed',
        'description': 'TestDesc',
        'frequency': 'Days of week',
        'times': ['08:00 AM'],
        'days': [true, false, false, false, false, false, false],
        'start_date': DateTime.now().toIso8601String(),
      }).select().single();
      print('Insert success: $insertRes');
    } catch(e) {
      print('Insert failed: $e');
    }
    exit(0);
  });
}
