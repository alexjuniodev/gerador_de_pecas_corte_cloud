# Configurador Alex Pro

Configurador de peças e orçamento de **um móvel por vez**, em MDF branco.
O orçamento, os materiais e a exportação acompanham automaticamente o móvel
em edição; não é necessário adicionar o móvel a uma lista.

## Medidas do móvel

As medidas iniciais são 1000 × 400 × 890 mm (comprimento × largura × altura).
A altura é editável e determina:

| Peça | Medida em função da altura |
| --- | --- |
| Coluna Interna | altura − 155 mm |
| Lateral Externa | altura |
| Porta Cava, incluindo a menor e as principais | altura − 270 mm |

As demais fórmulas de peças foram preservadas. Todas as peças e fitas são
brancas, incluindo o fundo, que mantém o material de 3 mm. O MDF estrutural
pode ter 15 ou 18 mm. Não há seleção de cores nem preço de chapa colorida.

Os campos aceitam decimais com ponto ou vírgula. Medidas e preços inválidos
exibem um aviso e impedem a exportação até serem corrigidos.

## Celular e computador

Em telas menores que 1000 pixels lógicos, os painéis ficam empilhados com
rolagem vertical. Em telas maiores, a configuração e as peças ficam ao lado
do orçamento. Os campos de medidas também se empilham quando falta espaço.
O site pode ser usado nas orientações retrato e paisagem.

## Exportar para o Cortecloud

Use **Baixar planilha Excel (.xlsx)** ou **Copiar para o Cortecloud** para
exportar somente as peças do móvel atual, com as medidas e espessura atuais.
O nome do móvel em Complemento inclui comprimento, largura e altura.

A planilha segue as 11 colunas do modelo do Cortecloud: Quantidade,
Comprimento, Largura, Função, Fita C1, Fita C2, Fita L1, Fita L2, Material,
Complemento e Girar. Medidas são numéricas; lados sem fita ficam vazios.

Para **Importar peças → Colar dados da planilha ou Excel**, copie pelo
aplicativo ou copie as linhas da planilha sem o cabeçalho. No Cortecloud,
vincule os nomes de chapas e fitas aos materiais disponíveis na central.
O campo Girar fica vazio para preservar o veio.

O número de chapas é estimado pela área útil de 4,5 m², sem otimização de
corte. O fundo de 3 mm é exportado, mas não integra o custo das chapas.

## Desenvolvimento e publicação

Com o SDK Flutter instalado:

```sh
flutter pub get
flutter test
flutter run -d chrome
```

Para gerar o site de produção:

```sh
flutter build web --release
```

Publique o conteúdo de `build/web/` no serviço de hospedagem utilizado.
Se o site for servido em uma subpasta, informe esse caminho com
`flutter build web --release --base-href /nome-da-subpasta/`.

Os testes cobrem as fórmulas de altura, as opções de portas e espessura,
exportação, atualização do orçamento, validação de entradas e layouts de
320 a 1440 pixels, incluindo redimensionamento, fonte ampliada e teclado.
