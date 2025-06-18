import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inteshar/app/config/constants.dart';
import 'package:inteshar/app/core/common/widgets/internal_page.dart';
import 'package:inteshar/app/core/common/widgets/offline_widget.dart';
import 'package:inteshar/app/features/home/data/data_source/home_api_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InternalPage(
      canBack: false,
      title: 'حول التطبيق',
      child: SingleChildScrollView( 
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 90),
          padding: const EdgeInsets.all(20),
          decoration: Constants.intesharBoxDecoration(context).copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
          height: 650,
          child: SingleChildScrollView(
            child: Obx(
              () {
                final updateController = Get.find<HomeApiProvider>();
                if (updateController.homeDataList.isEmpty) {
                  return const OfflineWidget();
                }
                return Text(
                  (updateController.homeDataList.first.user?.agent?.description !=
                              null &&
                          updateController.homeDataList.first.user!.agent!
                              .description!.isNotEmpty)
                      ? updateController
                          .homeDataList.first.user!.agent!.description!
                      : '''
                                  مع استمرار اعتماد العالم أكثر فأكثر على التكنولوجيا ، أصبحت شركات التكنولوجيا جزءًا لا يتجزأ من حياتنا اليومية. من تزويدنا بالأدوات التي نحتاجها للبقاء على اتصال ، إلى مساعدتنا في إيجاد طرق جديدة للقيام بالأشياء بشكل أسرع وأفضل ، تُحدث شركات التكنولوجيا ثورة في طريقة عيشنا.
      
                                  يعتمد نجاح أي عمل في جوهره على رضا العملاء وجودة المنتجات أو الخدمات. يجب أن تكون شركات التكنولوجيا قادرة على مواكبة المشهد التكنولوجي المتغير باستمرار من خلال مواكبة الاتجاهات وإنشاء حلول مبتكرة تلبي احتياجات العملاء.
      
                                  هناك العديد من العوامل التي تساهم في جعل شركة تكنولوجيا ناجحة ولكن بعض العوامل الرئيسية تشمل تصميم منتج ممتاز قيادة إستراتيجية لخدمة العملاء وتمكين بيئة العمل وتعزيز التعاون الإبداعي.
      
                                  ومن هذا المنطلق فإن “الانتشار” شركة رائدة في مجال توزيع بطاقات الهدايا الرقمية والخدمات الالكترونية، تتميز بطاقم اداري ذو خبرة واسعة في هذا المجال لتصبح بذلك واحدة من أفضل الشركات في المنطقة، توفر حلول تكنولوجية حديثة للتوزيع الإلكتروني، قابلة للتوسع والريادة، تسعى لكسب ثقة زبائتها من خلال توفير اكثر من ٢٠٠ نوعا من البطاقات، وباسعار تنافسية وخدمة دعم فني ممتازة، مما يسهل التعامل اليومي لاصحاب المحال التجارية بتوفير جميع الكروت والبطاقات بجميع الفئات.
      
                            ''',
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    height: 2.5,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
