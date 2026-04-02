import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../services/auth_service.dart';
import '../../services/posts_service.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;

  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  late final TextEditingController _imageUrlController;

  bool _isLoading = false;
  String? _error;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _textController = TextEditingController(text: widget.post?.text ?? '');
    _imageUrlController =
        TextEditingController(text: widget.post?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final service = PostsService();
    final imageUrl = _imageUrlController.text.trim();

    try {
      if (_isEditing) {
        await service.updatePost(Post(
          id: widget.post!.id,
          title: _titleController.text.trim(),
          text: _textController.text.trim(),
          authorEmail: widget.post!.authorEmail,
          createdAt: widget.post!.createdAt,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
        ));
      } else {
        final email = AuthService().currentUser?.email ?? '';
        await service.addPost(Post(
          id: '',
          title: _titleController.text.trim(),
          text: _textController.text.trim(),
          authorEmail: email,
          createdAt: DateTime.now(),
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
        ));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Ошибка сохранения: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'EDIT POST' : 'NEW STORY',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(context, 'CONTENT DETAILS'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Catchy Title',
                  hintText: 'Give your post a name...',
                  prefixIcon: Icon(Icons.auto_awesome_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Your Story',
                  hintText: 'What is on your mind?',
                  prefixIcon: Icon(Icons.bubble_chart_rounded),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Text is required' : null,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'VISUALS'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'Paste a link to an image...',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
                keyboardType: TextInputType.url,
              ),
              if (_error != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 50),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                  : FilledButton(
                      onPressed: _save,
                      child: Text(
                        _isEditing ? 'UPDATE POST' : 'PUBLISH NOW',
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
