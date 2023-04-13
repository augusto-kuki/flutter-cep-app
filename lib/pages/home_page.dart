import 'package:cep_app/models/endereco_model.dart';
import 'package:cep_app/repositories/cep_repository.dart';
import 'package:cep_app/repositories/cep_repository_impl.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CepRepository cepRepository = CepRepositoryImpl();

  EnderecoModel? enderecoModel;

  final formKey = GlobalKey<FormState>();
  final cepEC = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    cepEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar CEP'),
      ),
      body: SingleChildScrollView(
          child: Form(
        key: formKey,
        child: Column(children: [
          TextFormField(
            controller: cepEC,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Obrigatorio preencher o CEP!';
              }

              return null;
            },
          ),
          ElevatedButton(
              onPressed: () async {
                final isValid = formKey.currentState?.validate() ?? false;

                if (isValid) {
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    final endereco = await cepRepository.getCep(cepEC.text);

                    setState(() {
                      enderecoModel = endereco;
                      isLoading = false;
                    });
                  } catch (e) {
                    setState(() {
                      enderecoModel = null;
                      isLoading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Erro ao buscar endereco')));
                  }
                }
              },
              child: const Text('Buscar')),
          Visibility(
              visible: enderecoModel != null,
              child: Column(
                children: [
                  Text('Logradouro: ${enderecoModel?.logradouro ?? ''}'),
                  Text('Complemento: ${enderecoModel?.complemento ?? ''}'),
                  Text('CEP: ${enderecoModel?.cep ?? ''}')
                ],
              )),
          Visibility(
              visible: isLoading, child: const CircularProgressIndicator()),
        ]),
      )),
    );
  }
}
