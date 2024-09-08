import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helloworld/models/constants.dart';

class BotBehaviorCard extends StatefulWidget {
  @override
  _BotBehaviorCardState createState() => _BotBehaviorCardState();
}

class _BotBehaviorCardState extends State<BotBehaviorCard> {
  Map<String, dynamic>? botData;
  bool isLoading = true;
  bool thereIsData = true;
  late Constants _constants;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Mueve la inicialización del provider aquí
    _constants = Provider.of<Constants>(context, listen: false);
    _constants.addListener(_onConstantsChanged);

    // Llama al método para obtener los datos de Firebase
    _fetchDataFromFirebase();
  }

  @override
  void dispose() {
    _constants.removeListener(_onConstantsChanged);
    super.dispose();
  }

  void _onConstantsChanged() {
    if (mounted) {
      _fetchDataFromFirebase();
    }
  }

  Future<void> _fetchDataFromFirebase() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      thereIsData = false;
    });

    try {
      CollectionReference kbCollection =
          FirebaseFirestore.instance.collection('kbdata');
      QuerySnapshot snapshot = await kbCollection
          .where('botid', isEqualTo: _constants.botIdHeader)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          botData = {
            'title': data['email'],
            'kbid': data['kbid'],
            'wkid': data['wkid'],
            'bearer': data['bearer'],
            'botid': data['botid'],
            'botbehavior': data['botbehavior'],
            'icon': Icons.arrow_forward_ios,
            'docId': doc.id,
          };
          isLoading = false;
          thereIsData = true;
        });
      } else {
        setState(() {
          isLoading = false;
          thereIsData = false;
        });
      }
    } catch (e) {
      print('Error fetching data from Firebase: $e');
      setState(() {
        isLoading = false;
        thereIsData = false;
      });
    }
  }

  void _showEditDialog(BuildContext context, String field) {
    final TextEditingController controller =
        TextEditingController(text: botData?[field] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modificar ${field.toUpperCase()}'),
          content: TextField(
            minLines: 10,
            maxLines: 11,
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Nuevo valor',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _updateFirebaseData(field, controller.text);
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateFirebaseData(String field, String newValue) async {
    String docId = botData?['docId'];
    try {
      await FirebaseFirestore.instance
          .collection('kbdata')
          .doc(docId)
          .update({field: newValue});

      setState(() {
        botData?[field] = newValue;
      });

      print('Data updated successfully');
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : thereIsData
            ? AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _isMinimized ? 100 : 300,
                height: 150, // Fixed height
                curve: Curves.easeInOut,
                child: _isMinimized == false
                    ? Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.all(16),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          leading: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMinimized = !_isMinimized;
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.blue[50],
                              child: Icon(
                                botData?['icon'],
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          title: Text(
                            'Comportamiento del bot',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${botData?['botbehavior'] ?? ''}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showEditDialog(context, 'botbehavior'),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMinimized = false;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.blue[50],
                          child: Icon(
                            botData?['icon'],
                            color: Colors.blue,
                          ),
                        ),
                      ))
            : Center(
                child: Text('No hay comportamiento establecido para el bot.'),
              );
  }
}
