import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:untitled/Models/notes_model.dart';

import 'Boxes/boxes.dart';
void main() async
{
    WidgetsFlutterBinding.ensureInitialized();
    // var directory = await getApplicationDocumentsDirectory();
    await Hive.initFlutter();
    // Hive.init(directory.path);
    Hive.registerAdapter(NotesModelAdapter());
    // Hive.openBox('notes');
    await Hive.openBox<NotesModel>('notes');
    runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
    const MyApp({super.key});

    @override
    Widget build(BuildContext context)
    {
        return MaterialApp(

            theme: ThemeData(

                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)
            ),
            home: const MyHomePage()
        );
    }
}

class MyHomePage extends StatefulWidget
{
    const MyHomePage({super.key});

    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    @override
    Widget build(BuildContext context)
    {
        return Scaffold(
            appBar: AppBar(
                title: Text('Hive Database')
            ),
            body: ValueListenableBuilder<Box<NotesModel>>(valueListenable: Boxes.getData().listenable(), builder: (context, box, _)
                {
                    var data = box.values.toList().cast<NotesModel>();
                    return ListView.builder(
                        itemCount: box.length,
                        reverse: true,
                        shrinkWrap: true,
                        itemBuilder: (context, index)
                        {
                            return Container(
                                constraints: BoxConstraints(minHeight: 80),
                                child: Card(
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                                Row(
                                                    children: [
                                                        Expanded(
                                                            // width: 70,
                                                            child: Text(data[index].title.toString())),
                                                        // Spacer(),
                                                        SizedBox(width: 10),
                                                        InkWell(
                                                            onTap: ()
                                                            {
                                                                _editMyDialog(data[index], data[index].title.toString(), data[index].description.toString());
                                                            },
                                                            child: Icon(Icons.edit)),
                                                        SizedBox(width: 15),
                                                        InkWell(
                                                            onTap: ()
                                                            {
                                                                delete(data[index]);
                                                            },
                                                            child: Icon(Icons.delete, color: Colors.red))
                                                    ]
                                                ),
                                                Text(data[index].description.toString())
                                            ]
                                        )
                                    )
                                )
                            );
                        }
                    );

                }

            ),
            floatingActionButton: FloatingActionButton(onPressed: ()
                async
                {
                    _showMyDialog();
                },
                child: Icon(Icons.add))

        );
    }
    void delete(NotesModel notesModel) async
    {
        await notesModel.delete();
    }

    Future<void> _editMyDialog(NotesModel notesModel, String title, String description) async
    {
        titleController.text = title;
        descriptionController.text = description;
        return showDialog(context: context, builder: (context)
            {
                return AlertDialog(
                    title: Text('Edit Notes'),
                    content: SingleChildScrollView(
                        child: Column(
                            children: [
                                TextFormField(
                                    controller: titleController,
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                        hintText: 'Enter title',
                                        border: OutlineInputBorder()
                                    )
                                ),
                                SizedBox(
                                    height: 20
                                ),
                                TextFormField(
                                    controller: descriptionController,
                                    keyboardType: TextInputType.multiline,

                                    maxLines: null,
                                    decoration: InputDecoration(
                                        hintText: 'Enter description',
                                        border: OutlineInputBorder()
                                    )
                                )
                            ]
                        )
                    ),
                    actions: [
                        TextButton(onPressed: ()
                            {
                                Navigator.pop(context);
                            }, child: Text('cancel')),

                        TextButton(onPressed: ()
                            async
                            {
                                notesModel.title = titleController.text.toString();
                                notesModel.description = descriptionController.text.toString();
                                await notesModel.save();
                                titleController.clear();
                                descriptionController.clear();
                                Navigator.pop(context);
                            }, child: Text('Edit'))
                    ]
                );
            });
    }

    Future<void> _showMyDialog() async
    {
        return showDialog(context: context, builder: (context)
            {
                return AlertDialog(
                    title: Text('Add Notes'),
                    content: SingleChildScrollView(
                        child: Column(
                            children: [
                                TextFormField(
                                    controller: titleController,
                                    decoration: InputDecoration(
                                        hintText: 'Enter title',
                                        border: OutlineInputBorder()
                                    )
                                ),
                                SizedBox(
                                    height: 20
                                ),
                                TextFormField(
                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                        hintText: 'Enter description',
                                        border: OutlineInputBorder()
                                    )
                                )
                            ]
                        )
                    ),
                    actions: [
                        TextButton(onPressed: ()
                            {
                                Navigator.pop(context);
                            }, child: Text('cancel')),

                        TextButton(onPressed: ()
                            {
                                final data = NotesModel(title: titleController.text, description: descriptionController.text);
                                final box = Boxes.getData();
                                box.add(data);
                                data.save();
                                print(box);
                                titleController.clear();
                                descriptionController.clear();
                                Navigator.pop(context);
                            }, child: Text('Add'))
                    ]
                );
            });
    }
}
