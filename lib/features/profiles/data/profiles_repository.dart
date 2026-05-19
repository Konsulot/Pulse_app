import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/doctor_profile_model.dart';
import '../domain/profile_model.dart';

class ProfilesRepository {
  final SupabaseClient client;
  ProfilesRepository(this.client);

  Future<ProfileModel?> getCurrentProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final response = await client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (response == null) return null;
    return ProfileModel.fromJson(response);
  }

  Future<DoctorProfileModel?> getCurrentDoctorProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final doctor = await client
        .from('doctors')
        .select()
        .eq('profile_id', user.id)
        .maybeSingle();
    if (doctor != null) return DoctorProfileModel.fromJson(doctor);

    final profile = await getCurrentProfile();
    final name = _splitFullName(profile?.fullName ?? '');
    if (name == null) return null;

    return DoctorProfileModel(
      profileId: user.id,
      lastName: name.$1,
      firstName: name.$2,
      middleName: name.$3,
      clinicId: profile?.clinicId,
    );
  }

  Future<void> saveCurrentDoctorProfile({
    required String lastName,
    required String firstName,
    String? middleName,
    String? specialization,
    DateTime? birthDate,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован.');

    final profile = await getCurrentProfile();
    if (profile == null) throw Exception('Профиль пользователя не найден.');
    if (!profile.isDoctor) throw Exception('Редактирование профиля доступно только врачу.');

    final fullName = [
      lastName.trim(),
      firstName.trim(),
      if (_nullableText(middleName) != null) _nullableText(middleName)!,
    ].join(' ');

    final existingDoctor = await client
        .from('doctors')
        .select('id')
        .eq('profile_id', user.id)
        .maybeSingle();

    final data = <String, dynamic>{
      'profile_id': user.id,
      'clinic_id': profile.clinicId,
      'last_name': lastName.trim(),
      'first_name': firstName.trim(),
      'middle_name': _nullableText(middleName),
      'specialization': _nullableText(specialization),
      'birth_date': birthDate?.toIso8601String().split('T').first,
    };

    String doctorId;
    if (existingDoctor == null) {
      final inserted = await client.from('doctors').insert(data).select('id').single();
      doctorId = inserted['id'] as String;
    } else {
      doctorId = existingDoctor['id'] as String;
      await client.from('doctors').update(data).eq('id', doctorId);
    }

    await client.from('profiles').update(<String, dynamic>{
      'full_name': fullName,
      'doctor_id': doctorId,
    }).eq('id', user.id);
  }

  (String, String, String?)? _splitFullName(String value) {
    final parts = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.length < 2) return null;
    return (parts[0], parts[1], parts.length > 2 ? parts.sublist(2).join(' ') : null);
  }

  String? _nullableText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
