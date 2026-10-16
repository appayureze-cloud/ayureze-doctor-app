import 'package:flutter/material.dart';
import 'package:doctro/constant/preferences.dart';
import 'package:doctro/constant/prefConstatnt.dart';
import 'package:doctro/services/astra_api_service.dart';
import 'package:doctro/screens/astra/case_progress_screen.dart';

/// Lists the clinical cases assigned to this doctor
/// (`GET /api/companion/case/by-doctor/{doctor_id}`) - the real,
/// role-gated endpoint that exists for exactly this, but previously had no
/// caller anywhere in this app.
class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({Key? key}) : super(key: key);

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
  final AstraApiService _astraApiService = AstraApiService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _cases = [];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final doctorId = SharedPreferenceHelper.getString(Preferences.doctorId);
      if (doctorId.isEmpty || doctorId == 'N_A') {
        setState(() {
          _error = 'Doctor session missing. Please login again.';
          _isLoading = false;
        });
        return;
      }
      final cases = await _astraApiService.getCasesByDoctor(doctorId);
      setState(() {
        _cases = cases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load cases. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cases')),
      body: RefreshIndicator(
        onRefresh: _loadCases,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _cases.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'No cases assigned yet.\nCases appear here once a '
                              'prescription is approved for a patient.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _cases.length,
                        itemBuilder: (context, index) {
                          final c = _cases[index] as Map<String, dynamic>;
                          final diagnosis =
                              c['diagnosis']?.toString() ?? 'No diagnosis recorded';
                          final status = c['status']?.toString() ?? 'open';
                          final caseId =
                              c['case_id']?.toString() ?? c['id']?.toString() ?? '';
                          final appointmentId = (c['metadata']
                              as Map<String, dynamic>?)?['appointment_id']
                              ?.toString();
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(diagnosis),
                              subtitle: Text('Case ID: $caseId\nStatus: $status'
                                  '${appointmentId != null ? '\nAppointment: $appointmentId' : ''}'),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CaseProgressScreen(caseData: c),
                                  ),
                                );
                                if (mounted) _loadCases();
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
