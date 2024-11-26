import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AllowedCardsPage extends StatefulWidget {
  const AllowedCardsPage({super.key});

  @override
  State<AllowedCardsPage> createState() => _AllowedCardsPageState();
}

class _AllowedCardsPageState extends State<AllowedCardsPage> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref('allowedCards');
  Map<dynamic, dynamic> _allowedCards = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllowedCards();
  }

  void _fetchAllowedCards() {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      setState(() {
        _allowedCards = data;
        _isLoading = false;
      });
    });
  }

  void _editCard(String key, String currentName) {
    TextEditingController controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sửa thẻ"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nhập tên mới"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                String newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  _databaseRef.child(key).set(newName);
                  Navigator.pop(context);
                }
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  void _deleteCard(String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xóa thẻ"),
          content: const Text("Bạn có chắc chắn muốn xóa thẻ này?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                _databaseRef.child(key).remove();
                Navigator.pop(context);
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách thẻ"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allowedCards.isEmpty
              ? const Center(child: Text("Không có thẻ nào."))
              : ListView.builder(
                  itemCount: _allowedCards.length,
                  itemBuilder: (context, index) {
                    String key = _allowedCards.keys.elementAt(index);
                    String value = _allowedCards[key];

                    return ListTile(
                      title: Text(value),
                      subtitle: Text("Mã thẻ: $key"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editCard(key, value),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCard(key),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
