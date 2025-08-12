import 'package:flash_task/widgets/gradient_background.dart';
import 'package:flash_task/widgets/gradient_outlineInput_border.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task;
  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedTag;
  String? _selectedPriority;
  DateTime? _dueDate;
  bool _isSaving = false;
  String _selectedStatus = 'To Do';

  final List<String> _statuses = ['To Do', 'In Progress', 'Done'];
  final List<String> _tags = ['Work', 'Study', 'Personal', 'Idea'];
  final List<String> _priorities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedTag = widget.task?.tag;
    _selectedPriority = widget.task?.priority;
    _dueDate = widget.task?.dueDate;
    _selectedStatus = widget.task?.status ?? 'To Do';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      DateTime finalDt = picked;
      if (time != null) {
        finalDt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
      }
      setState(() => _dueDate = finalDt);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final id = widget.task?.id ?? const Uuid().v4();
    final task = Task(
      id: id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      tag: _selectedTag,
      priority: _selectedPriority,
      dueDate: _dueDate,
      status: _selectedStatus,
    );

    try {
      if (widget.task == null) {
        await _apiService.addTask(task);
      } else {
        await _apiService.updateTask(task);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(isEdit ? 'Edit Task' : 'Add Task'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        label: ShaderMask(
                          shaderCallback: (bounds) =>
                              LinearGradient(
                                colors: [
                                  Color(0xFF8E7DBE),
                                  Color(0xFF8E7DBE),
                                  Color(0xFF8E7DBE),
                                  Color(0xFF8E7DBE),
                                ],
                              ).createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              ),
                          child: const Text(
                            'Title',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        border: GradientOutlineInputBorder(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF7CFD8),
                              Color(0xFFF4F8D3),
                              Color(0xFFA6D6D6),
                              Color(0xFF8E7DBE),
                            ],
                          ),
                        ),
                        enabledBorder: GradientOutlineInputBorder(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF7CFD8),
                              Color(0xFFF4F8D3),
                              Color(0xFFA6D6D6),
                              Color(0xFF8E7DBE),
                            ],
                          ),
                        ),
                        focusedBorder: GradientOutlineInputBorder(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8E7DBE),
                              Color(0xFFA6D6D6),
                              Color(0xFFF4F8D3),
                              Color(0xFFF7CFD8),
                            ],
                          ),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Please enter title'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        label: ShaderMask(
                          shaderCallback: (bounds) =>
                              LinearGradient(
                                colors: [
                                  Color(0xFF8E7DBE),
                                  Color(0xFF8E7DBE),
                                  Color(0xFF8E7DBE),
                                  Color(0xFF8E7DBE),
                                ],
                              ).createShader(
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              ),
                          child: const Text(
                            'Description',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        border: GradientOutlineInputBorder(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E7DBE)],
                          ),
                        ),
                        enabledBorder: GradientOutlineInputBorder(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF7CFD8),
                              Color(0xFFF4F8D3),
                              Color(0xFFA6D6D6),
                              Color(0xFF8E7DBE),
                            ],
                          ),
                        ),
                        focusedBorder: GradientOutlineInputBorder(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8E7DBE),
                              Color(0xFFA6D6D6),
                              Color(0xFFF4F8D3),
                              Color(0xFFF7CFD8),
                            ],
                          ),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Please enter description'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedTag,
                            isExpanded: true,
                            items: [null, ..._tags].map((t) {
                              return DropdownMenuItem<String>(
                                value: t,
                                child: Text(t ?? 'No tag'),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedTag = v),
                            decoration: InputDecoration(
                              labelText: 'Tag',
                              labelStyle: TextStyle(color: Color(0xFF8E7DBE)),
                              border: GradientOutlineInputBorder(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF7CFD8),
                                    Color(0xFFF4F8D3),
                                    Color(0xFFA6D6D6),
                                    Color(0xFF8E7DBE),
                                  ],
                                ),
                              ),
                              enabledBorder: GradientOutlineInputBorder(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF7CFD8),
                                    Color(0xFFF4F8D3),
                                    Color(0xFFA6D6D6),
                                    Color(0xFF8E7DBE),
                                  ],
                                ),
                              ),
                              focusedBorder: GradientOutlineInputBorder(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8E7DBE),
                                    Color(0xFFA6D6D6),
                                    Color(0xFFF4F8D3),
                                    Color(0xFFF7CFD8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            items: [null, ..._priorities].map((p) {
                              return DropdownMenuItem<String>(
                                value: p,
                                child: Text(p ?? 'No priority'),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _selectedPriority = v),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: TextStyle(color: Color(0xFF8E7DBE)),
                              border: GradientOutlineInputBorder(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF7CFD8),
                                    Color(0xFFF4F8D3),
                                    Color(0xFFA6D6D6),
                                    Color(0xFF8E7DBE),
                                  ],
                                ),
                              ),
                              enabledBorder: GradientOutlineInputBorder(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF7CFD8),
                                    Color(0xFFF4F8D3),
                                    Color(0xFFA6D6D6),
                                    Color(0xFF8E7DBE),
                                  ],
                                ),
                              ),
                              focusedBorder: GradientOutlineInputBorder(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8E7DBE),
                                    Color(0xFFA6D6D6),
                                    Color(0xFFF4F8D3),
                                    Color(0xFFF7CFD8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: OutlinedButton.icon(
                              onPressed: _pickDueDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                _dueDate == null
                                    ? 'Set due date'
                                    : _dueDate!.toLocal().toString(),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF8E7DBE),
                                side: BorderSide(
                                  color: Color(0xFF8E7DBE).withOpacity(0.5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_dueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _dueDate = null),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: _statuses
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedStatus = val;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Status',
                        labelStyle: TextStyle(color: Color(0xFF8E7DBE)),
                        border: GradientOutlineInputBorder(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF7CFD8),
                              Color(0xFFF4F8D3),
                              Color(0xFFA6D6D6),
                              Color(0xFF8E7DBE),
                            ],
                          ),
                        ),
                        enabledBorder: GradientOutlineInputBorder(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF7CFD8),
                              Color(0xFFF4F8D3),
                              Color(0xFFA6D6D6),
                              Color(0xFF8E7DBE),
                            ],
                          ),
                        ),
                        focusedBorder: GradientOutlineInputBorder(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8E7DBE),
                              Color(0xFFA6D6D6),
                              Color(0xFFF4F8D3),
                              Color(0xFFF7CFD8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFF8E7DBE),
                        ),
                        onPressed: _isSaving ? null : _saveTask,
                        child: _isSaving
                            ? const CircularProgressIndicator()
                            : Text(
                                isEdit ? 'Update' : 'Add',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
