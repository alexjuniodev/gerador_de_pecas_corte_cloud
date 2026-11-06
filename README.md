# gerador_de_pecas_corte_cloud

## Exportar para o Cortecloud

Adicione os móveis ao orçamento e use **Baixar planilha Excel (.xlsx)**.
A planilha segue as 11 colunas do modelo do Cortecloud: Quantidade,
Comprimento, Largura, Função, Fita C1, Fita C2, Fita L1, Fita L2, Material,
Complemento e Girar. Medidas são numéricas; lados sem fita ficam vazios.
O nome do móvel vai em Complemento, e cada móvel mantém sua espessura de MDF.

Para o fluxo **Importar peças → Colar dados da planilha ou Excel**, use
**Copiar para o Cortecloud** no aplicativo ou copie as linhas da planilha Excel,
sem o cabeçalho. No Cortecloud, vincule os nomes de chapas e fitas aos materiais
disponíveis na central. O campo Girar fica vazio para preservar o veio.

O antigo CSV tinha colunas incompatíveis com o modelo e foi substituído pelo
arquivo Excel. Nenhuma dependência nova é necessária para gerar a planilha.

Referência: [tutorial de importação do Cortecloud](https://ajuda.cortecloud.com.br/help/como-importar-lista-de-pecas-do-excel-para-o-cortecloud).

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
