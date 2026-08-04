// // ignore_for_file: prefer_const_constructors, must_be_immutable
//
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:store_go_app/utils/colors.dart';
// import 'package:store_go_app/utils/text_style.dart';
// import 'package:store_go_app/view/widget/common_button.dart';
// import 'package:store_go_app/view/widget/common_appbar_widget.dart';
// import 'package:store_go_app/view/widget/common_drop_down_widget.dart';
// import 'package:store_go_app/view/widget/common_space_divider_widget.dart';
// import 'package:store_go_app/view/screen/product_screen/product_widget.dart';
// import 'package:store_go_app/core/controller/product_controller/add_product_controller.dart';
//
// class AddVariantScreen extends StatelessWidget {
//   AddVariantScreen({Key? key}) : super(key: key);
//   AddProductController addProductController = Get.put(AddProductController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.cBackGround,
//       appBar: simpleAppBar(title: 'Add Variant', date: ""),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Add Variant",
//                 style: pRegular20,
//               ),
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10),
//                 child: horizontalDivider(),
//               ),
//               AddProductTextField(
//                 controller: addProductController.variantName.value,
//                 labelText: 'Name',
//                 hintText: 'Enter variant name',
//               ),
//               commonHintDropdownWidget(
//                 labelText: 'Variant Type',
//                 list: addProductController.variantTypeList,
//                 onChanged: (value) {
//                   addProductController.variantType.value = value;
//                 },
//                 value: addProductController.variantType.value,
//               ),
//               verticalSpace(25),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CommonButton(
//                       title: 'Cancel',
//                       onPressed: () {},
//                       btnColor: AppColor.cButton,
//                       textColor: AppColor.cDarkGreyFont,
//                     ),
//                   ),
//                   horizontalSpace(25),
//                   Expanded(
//                     child: CommonButton(
//                       title: 'Create',
//                       onPressed: () {},
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
