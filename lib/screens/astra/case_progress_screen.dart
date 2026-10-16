import 'package:flutter/material.dart';
import 'package:doctro/services/astra_api_service.dart';

/// Lets a doctor review and update a case's progress/adherence
/// (`PUT /api/companion/case/progress`) - covers "ongoing supervision":
/// progress reports, missed-dose concerns and adverse-effect notes all go
/// in the free-text `notes` field, matching exactly what the real
/// backend's `UpdateProgressRequest` supports (progress_percentage,
/// adherence_score, notes - no separate fields for those exist
/// server-side). Reaching 100% auto-resolves the linked journey
/// server-side.
class CaseProgressScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;

  const CaseProgressScreen({Key? key, required this.caseData})
      : super(key: key);

  @override
  State<CaseProgressScreen> createState() => _CaseProgressScreenState();
}

class _CaseProgressScreenState extends State<CaseProgressScreen> {
  final AstraApiService _astraApiService = AstraApiService();
  final _notesController = TextEditingController();
  double _progress = 0;
  double _adherence = 100;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.caseData['progress_percentage'];
    final a = widget.caseData['adherence_score'];
    if (p is num) _progress = p.toDouble().clamp(0, 100);
    if (a is num) _adherence = a.toDouble().clamp(0, 100);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String get _caseId =>
      widget.caseData['case_id']?.toString() ??
      widget.caseData['id']?.toString() ??
      '';

  Future<void> _save() async {
    if (_caseId.isEmpty) return;
    setState(() => _saving = true);
    final ok = await _astraApiService.updateCaseProgress(
      caseId: _caseId,
      progressPercentage: _progress,
      adherenceScore: _adherence,
      notes: _notesController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Progress updated.'
          : 'Could not update progress. Please try again.'),
    ));
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final diagnosis =
        widget.caseData['diagnosis']?.toString() ?? 'No diagnosis recorded';
    return Scaffold(
      appBar: AppBar(title: const Text('Case Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(diagnosis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text('Case ID: $_caseId',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          Text('Progress: ${_progress.round()}%'),
          Slider(
            value: _progress,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_progress.round()}%',
            onChanged: (v) => setState(() => _progress = v),
          ),
          const SizedBox(height: 12),
          Text('Adherence: ${_adherence.round()}%'),
          Slider(
            value: _adherence,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_adherence.round()}%',
            onChanged: (v) => setState(() => _adherence = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes (missed doses, side effects, follow-up plan...)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save progress'),
          ),
          if (_progress >= 100)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Reaching 100% marks the treatment journey as resolved.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
