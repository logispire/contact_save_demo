import 'dart:developer';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Save"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              onPressed: () async {
                if (await Permission.contacts.request().isGranted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return const SaveContactDialog();
                    },
                  );
                }
              },
              icon: const Icon(
                Icons.save_alt_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: memberList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberList[index].name,
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  "Mobile No: ${memberList[index].mobileNumber}",
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            subtitle: Text(memberList[index].companyName),
          );
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SaveContactDialog extends StatefulWidget {
  const SaveContactDialog({Key? key}) : super(key: key);

  @override
  State<SaveContactDialog> createState() => _SaveContactDialogState();
}

class _SaveContactDialogState extends State<SaveContactDialog> {
  bool isLoading = false;

  saveContacts() async {
    setState(() {
      isLoading = true;
    });
    List<Contact> contactData =
        await ContactsService.getContacts(withThumbnails: false);
    try {
      List<Contact> updatableContacts = [];
      List<Contact> addContacts = [];
      for (int i = 0; i < memberList.length; i++) {
        if (mounted) {
          final name = memberList[i].name;
          final mobileNo = memberList[i].mobileNumber;
          final companyName = memberList[i].companyName;
          bool duplicateFound = false;
          for (var element in contactData) {
            if (element.phones != null) {
              for (var contact in element.phones!) {
                if (contact.value?.contains(mobileNo) == true) {
                  element.givenName = name;
                  element.identifier = element.identifier;
                  element.company = companyName;
                  element.androidAccountName = name;
                  element.phones = [Item(value: mobileNo)];
                  updatableContacts.add(element);
                  duplicateFound = true;
                  break;
                }
              }
              if (duplicateFound) {
                break;
              }
            }
          }
          if (!duplicateFound) {
            final contact = Contact(
              phones: [Item(value: mobileNo)],
              givenName: name,
              androidAccountName: name,
              company: companyName,
            );

            addContacts.add(contact);
          }
        }
      }

      log("update contact ${updatableContacts.length}");
      log("add contact ${addContacts.length}");

      await Future.forEach(addContacts, (element) async {
        await ContactsService.addContact(element);
        log("Contact save ${element.givenName} ${element.phones?[0].value}");
      });

      await Future.forEach(updatableContacts, (element) async {
        await ContactsService.updateContact(element);
        log("Contact update ${element.givenName} ${element.phones?[0].value}");
      });

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "All contact saved successfully");
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("contact save error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Contact Save"),
      content: const Text(
        "Save all members contacts in your phone?\nBy click confirm all contact will be saved",
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("No"),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: isLoading ? null : saveContacts,
                  child: const Text("Yes"),
                ),
              ],
            ),
            if (isLoading)
              const Text(
                "Please wait for 2 minutes",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
          ],
        )
      ],
    );
  }
}

class Member {
  String name;
  String companyName;
  String mobileNumber;

  Member({
    required this.name,
    required this.companyName,
    required this.mobileNumber,
  });
}

List<Member> memberList = [
  Member(name: "person 1", companyName: "company 1", mobileNumber: "101"),
  Member(name: "person 2", companyName: "company 2", mobileNumber: "102"),
  Member(name: "person 3", companyName: "company 3", mobileNumber: "103"),
  Member(name: "person 4", companyName: "company 4", mobileNumber: "104"),
  Member(name: "person 5", companyName: "company 5", mobileNumber: "105"),
  Member(name: "person 6", companyName: "company 6", mobileNumber: "106"),
  Member(name: "person 7", companyName: "company 7", mobileNumber: "107"),
  Member(name: "person 8", companyName: "company 8", mobileNumber: "108"),
  Member(name: "person 9", companyName: "company 9", mobileNumber: "109"),
  Member(name: "person 10", companyName: "company 10", mobileNumber: "110"),
  Member(name: "person 11", companyName: "company 11", mobileNumber: "111"),
  Member(name: "person 12", companyName: "company 12", mobileNumber: "112"),
  Member(name: "person 13", companyName: "company 13", mobileNumber: "113"),
  Member(name: "person 14", companyName: "company 14", mobileNumber: "114"),
  Member(name: "person 15", companyName: "company 15", mobileNumber: "115"),
  Member(name: "person 16", companyName: "company 16", mobileNumber: "116"),
  Member(name: "person 17", companyName: "company 17", mobileNumber: "117"),
  Member(name: "person 18", companyName: "company 18", mobileNumber: "118"),
  Member(name: "person 19", companyName: "company 19", mobileNumber: "119"),
  Member(name: "person 20", companyName: "company 20", mobileNumber: "120"),
  Member(name: "person 21", companyName: "company 21", mobileNumber: "121"),
  Member(name: "person 22", companyName: "company 22", mobileNumber: "122"),
  Member(name: "person 23", companyName: "company 23", mobileNumber: "123"),
  Member(name: "person 24", companyName: "company 24", mobileNumber: "124"),
  Member(name: "person 25", companyName: "company 25", mobileNumber: "125"),
  Member(name: "person 26", companyName: "company 26", mobileNumber: "126"),
  Member(name: "person 27", companyName: "company 27", mobileNumber: "127"),
  Member(name: "person 28", companyName: "company 28", mobileNumber: "128"),
  Member(name: "person 29", companyName: "company 29", mobileNumber: "129"),
  Member(name: "person 30", companyName: "company 30", mobileNumber: "130"),
  Member(name: "person 31", companyName: "company 31", mobileNumber: "131"),
  Member(name: "person 32", companyName: "company 32", mobileNumber: "132"),
  Member(name: "person 33", companyName: "company 33", mobileNumber: "133"),
  Member(name: "person 34", companyName: "company 34", mobileNumber: "134"),
  Member(name: "person 35", companyName: "company 35", mobileNumber: "135"),
  Member(name: "person 36", companyName: "company 36", mobileNumber: "136"),
  Member(name: "person 37", companyName: "company 37", mobileNumber: "137"),
  Member(name: "person 38", companyName: "company 38", mobileNumber: "138"),
  Member(name: "person 39", companyName: "company 39", mobileNumber: "139"),
  Member(name: "person 40", companyName: "company 40", mobileNumber: "140"),
];
