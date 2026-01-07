import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mental_app/core/network/dio_client.dart';
import 'package:mental_app/data/datasources/remote/practice_remote_data_source.dart';
import 'package:mental_app/data/datasources/remote/user_method_remote_data_source.dart';
import 'package:mental_app/data/repositories/practice_repository_impl.dart';
import 'package:mental_app/data/repositories/user_method_repository_impl.dart';
import 'package:mental_app/presentation/practice/bloc/practice_record_bloc.dart';
import 'package:mental_app/presentation/practice/bloc/practice_record_event.dart';
import 'package:mental_app/presentation/practice/bloc/practice_record_state.dart';
import 'package:mental_app/presentation/widgets/loading_indicator.dart';

/// 练习记录创建页面
class PracticeRecordCreatePage extends StatelessWidget {
  final int? userMethodId;

  const PracticeRecordCreatePage({
    super.key,
    this.userMethodId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dioClient = DioClient();
        final practiceDataSource = PracticeRemoteDataSource(dioClient);
        final userMethodDataSource = UserMethodRemoteDataSource(dioClient);
        final practiceRepository =
            PracticeRepositoryImpl(remoteDataSource: practiceDataSource);
        final userMethodRepository =
            UserMethodRepositoryImpl(remoteDataSource: userMethodDataSource);

        return PracticeRecordBloc(
          practiceRepository: practiceRepository,
          userMethodRepository: userMethodRepository,
        )..add(LoadUserMethodsForPractice());
      },
      child: _PracticeRecordCreateView(userMethodId: userMethodId),
    );
  }
}

class _PracticeRecordCreateView extends StatefulWidget {
  final int? userMethodId;

  const _PracticeRecordCreateView({this.userMethodId});

  @override
  State<_PracticeRecordCreateView> createState() =>
      _PracticeRecordCreateViewState();
}

class _PracticeRecordCreateViewState
    extends State<_PracticeRecordCreateView> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedMethodId;
  int _durationMinutes = 10;
  double _moodBefore = 5;
  double _moodAfter = 5;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMethodId = widget.userMethodId;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录练习'),
      ),
      body: BlocConsumer<PracticeRecordBloc, PracticeRecordState>(
        listener: (context, state) {
          if (state is PracticeRecordCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('练习记录创建成功')),
            );
            Navigator.pop(context);
          } else if (state is PracticeRecordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PracticeRecordLoading) {
            return const Center(child: LoadingIndicator());
          }

          final userMethods = state is UserMethodsLoaded
              ? state.userMethods
              : (state is PracticeRecordCreating ? [] : []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 选择方法
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '选择方法',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedMethodId,
                            decoration: const InputDecoration(
                              labelText: '练习方法',
                              border: OutlineInputBorder(),
                            ),
                            items: userMethods
                                .map((um) => DropdownMenuItem(
                                      value: um.id,
                                      child: Text(um.method.name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMethodId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return '请选择练习方法';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 练习时长
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '练习时长',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '$_durationMinutes 分钟',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _durationMinutes.toDouble(),
                            min: 1,
                            max: 120,
                            divisions: 119,
                            label: '$_durationMinutes 分钟',
                            onChanged: (value) {
                              setState(() {
                                _durationMinutes = value.toInt();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 心理状态评分
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '心理状态评分',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),

                          // 练习前评分
                          Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  '练习前',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: _moodBefore,
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  label: _moodBefore.toInt().toString(),
                                  activeColor: Colors.orange,
                                  onChanged: (value) {
                                    setState(() {
                                      _moodBefore = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '${_moodBefore.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // 练习后评分
                          Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  '练习后',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: _moodAfter,
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  label: _moodAfter.toInt().toString(),
                                  activeColor: Colors.green,
                                  onChanged: (value) {
                                    setState(() {
                                      _moodAfter = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '${_moodAfter.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 备注
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '备注（可选）',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 4,
                            maxLength: 500,
                            decoration: const InputDecoration(
                              hintText: '记录你的感受和体会...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 提交按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is PracticeRecordCreating
                          ? null
                          : _submitForm,
                      child: state is PracticeRecordCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '提交记录',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<PracticeRecordBloc>().add(
            CreatePracticeRecord(
              userMethodId: _selectedMethodId!,
              durationMinutes: _durationMinutes,
              moodBefore: _moodBefore.toInt(),
              moodAfter: _moodAfter.toInt(),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            ),
          );
    }
  }
}
