import 'package:flutter/material.dart';
import '../../../constants/style.dart';
import '../../../components/page_title.dart';
import '../../../utils/responsive.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final List<String> images = []; // Empty list instead of demo images

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            PageTitle(
              title: "Gallery",
              subtitle: "View delivery and logistics operations",
              icon: Icons.photo_library,
              actions: [
                IconButton(
                  icon: Icon(Icons.add_photo_alternate),
                  tooltip: 'Add Image',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Upload functionality coming soon')),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Container(
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Images",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: defaultPadding),
                  images.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: defaultPadding),
                              Text(
                                "No images available",
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: defaultPadding / 2),
                              Text(
                                "Click the + button to add images",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
                            crossAxisSpacing: defaultPadding,
                            mainAxisSpacing: defaultPadding,
                            childAspectRatio: 1,
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _showImageDialog(context, images[index]),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 4),
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Stack(
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
