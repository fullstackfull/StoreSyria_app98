// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:store_go_app/config/repository/search_repository.dart';
import 'package:store_go_app/config/repository/category_repository.dart';
import 'package:store_go_app/utils/prefer.dart';
import 'package:store_go_app/utils/base_api.dart';
import 'package:store_go_app/view/widget/loading_widget.dart';
import 'package:store_go_app/core/model/categories_model.dart';
import 'package:store_go_app/view/widget/common_snak_bar_widget.dart';

class CategoryController extends GetxController{
  TextEditingController categoryName=TextEditingController();
  TextEditingController searchController=TextEditingController();
  RxString filePath=''.obs;
  RxString imagePath=''.obs;
  RxString iconPath=''.obs;
  RxString trending='1'.obs;
  RxBool isTrending=true.obs;
  RxInt currantPage=1.obs;
  RxBool isScroll=true.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;


  CategoryRepository categoryRepository=CategoryRepository();
  SearchRepository searchRepository=SearchRepository();

  CategoriesModel? categoriesModel;
  CategoryData? categoryData;
  RxList<CategoryData> categoriesList=<CategoryData>[].obs;

  pickFile() async{
    FilePickerResult? result=await FilePicker.pickFiles();
    if(result!=null){
      File file=File(result.files.single.path!);
      print(file.path);
      return file.path;
    }else{
      commonToast('File not pick');
    }
  }

  getCategoryData(page) async{
    isLoading.value = true;
    Loader.showLoader();
    final response=await categoryRepository.getCategoriesData(page);
    response.fold(
      onSuccess:(data){
        isLoading.value = false;
        if(data['status']==1){
          categoriesModel=CategoriesModel.fromJson(data);
          categoriesList.value=categoriesModel?.data?.data??[];
          categoriesList.refresh();
          if(currantPage.value==categoriesModel?.data?.lastPage){
            isScroll.value=false;
          }
        }else{
          commonToast(data['data']['message']??'');
        }
      },
      onFailure:(reason,message,errors){
        errorMessage.value = message;
        commonToast(message);
      },
    );
    Get.back();
  }

  searchCategoryData({required String name}) async{
    Loader.showLoader();
    final response=await searchRepository.getSearchData(type:"category",name:name);
    response.fold(
      onSuccess:(data){
        categoriesList.clear();
        if(data['status']==1){
          for(int i=0;i<data['data'].length;i++){
            categoriesList.add(CategoryData.fromJson(data['data'][i]));
          }
          categoriesList.refresh();
        }else{
          commonToast(data['data']['message']??'');
        }
      },
      onFailure:(reason,message,errors){
        commonToast(message);
      },
    );
    Get.back();
  }

  addCategoriesData({
    required bool isUpdate,
    required int categoryId,
    required String name,
    required String trending,
    required String status,
    required String? imagePath,
    required String? iconImagePath,
  }) async{
    Loader.showLoader();
    String url=isUpdate?API.baseUrl+API.updateCategoryUrl:API.baseUrl+API.addCategoryUrl;
    var data=isUpdate?{
      'store_id':Prefs.getStoreID(),
      'category_id':categoryId.toString(),
      'name':name,
      'trending':trending,
      'status':status
    }:{
      'store_id':Prefs.getStoreID(),
      'name':name,
      'trending':trending,
      'status':status
    };
    var request=http.MultipartRequest('POST',Uri.parse(url));
    request.fields.addAll(data);
    if(imagePath!=null&&imagePath.isNotEmpty){
      request.files.add(await http.MultipartFile.fromPath('image',imagePath));
    }
    if(iconImagePath!=null&&iconImagePath.isNotEmpty){
      request.files.add(await http.MultipartFile.fromPath('icon_image',iconImagePath));
    }
    request.headers.addAll({
      "Authorization":'Bearer ${Prefs.getToken()}',
      HttpHeaders.cacheControlHeader:"no-cache",
    });
    http.StreamedResponse response=await request.send();
    Loader.hideLoader();
    if(response.statusCode==200){
      var responseData=await response.stream.bytesToString();
      var decodedData=jsonDecode(responseData);
      commonToast(decodedData['data']['message']);
      getCategoryData(currantPage.value);
    }else{
      commonToast(response.reasonPhrase??'');
    }
  }

  deleteCategoriesData({required int categoryId}) async{
    Loader.showLoader();
    final response=await categoryRepository.deleteCategoriesData(categoryId:categoryId);
    response.fold(
      onSuccess:(data){
        commonToast(data['data']['message']??'');
        getCategoryData(currantPage.value);
      },
      onFailure:(reason,message,errors){
        commonToast(message);
      },
    );
  }
}