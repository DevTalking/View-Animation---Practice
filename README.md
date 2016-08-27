# iOS UIView Animation - Practice
[原文链接][1]
## 前言
上三篇关于UIView Animation的文章向大家介绍了基础的UIView动画，包括移动位置、改变大小、旋转、弹簧动画、过渡动画。这些虽然看起来很简单，但是如果我们仔细分析、分解一个复杂动画时，就会发现这些复杂的动画其实是由若干基础的动画组合而成的。今天这篇文章是实践篇，我选择了Raywenderlich [Top 5 iOS 7 Animations][2]这篇文章中的一个动画效果，带大家一起实现。要实现这个动画效果，除了用到我们上三篇介绍过的知识点以外，还有两个知识点在这篇会介绍给大家，我们先看看实现的效果：

![][image-1]

这个动画示例实现的是一个展示航班信息的应用，左右滑动显示不同的航班信息。我们可以分析一下都用到了哪些动画：

- 淡入淡出：起飞地和目的地、起飞地和目的地下面的横线、底部的航班时间都使用了该动画。
- 位置移动：起飞地和目的地、小飞机都使用了该动画。
- 旋转：航站楼登机口前面的小箭头、小飞机都使用了该动画。
- 过渡动画： 背景图片使用了淡入淡出效果的图片替换过渡动画。
- 伪3D动画：顶部的时间、航班号、航站楼登机口信息、底部的起飞降落文字都是用了该动画。

前三个动画我们之前已经介绍过了，现在我们来介绍后两个动画。

## 伪3D动画效果
这个伪3D的效果模拟的是一个立体长方形由一面翻转到另一面。因为这不是真正的3D效果，所以我们可以分析一下它是如何模拟的，以上面动画中从下往上翻的效果为例。首先显示的是一个`UILabel`，当开始进行翻转时，当前显示的`UILabel`的高度开始慢慢变矮：

![Practice-1][image-2]

我们看看用代码怎么实现：

``` swift

UIView.animateWithDuration(1, animations: {
    self.devtalkingLabel.transform = CGAffineTransformMakeScale(1.0, 0.5)
})

```

我们可以使用一个转换动画，使用`CGAffineTransformMakeScale`，它的第一个参数是x坐标的比例，第二个参数是y坐标的比例，这两个值的范围是1.0到0之间。上面的代码用白话文翻译出来就是在1秒内，`devtalkingLabel`的宽度不变，高度减少一半，减少的过程会自动生成补间动画。

我们接着来分析，在`UILabel`高度减少的同时，它的位置也会向上移动，我们可以用另外一个转换的动画：

``` swift

UIView.animateWithDuration(1, animations: {
    self.devtalkingLabel.transform = CGAffineTransformMakeScale(1.0, 0.5)
    self.devtalkingLabel.transform = CGAffineTransformMakeTranslation(1.0, -self.devtalkingLabel.frame.height / 2)
})

```

`CGFffineTransformMakeTranslation`这个转换动画可以移动UIView的位置，这里需要注意它是以初始位置为基础进行移动的，所以上述代码在字面上的意思是`devtalkingLabel`在高度变小的同时向上移动它初始宽度一半的距离：

![Practice-2][image-3]

但是当我们编译运行后发现事与愿违，转换动画不像动画属性动画那样可以在`animations`闭包中写多个进行组合，而是由另一个组合转换动画来实现：

``` swift

UIView.animateWithDuration(1, animations: {
    self.devtalkingLabel.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.5), CGAffineTransformMakeTranslation(1.0, -self.devtalkingLabel.frame.height / 2))
    self.devtalkingLabel.alpha = 0
})

```

来看看效果：

![Practice-4][image-4]

此时，3D翻转效果的一个面已经成型了，也就是当前显示的这一面被向上翻转到顶部去了。接下来我们要实现底部的面翻转到当前显示的这一面。很明显这需要两个面，但我们只有一个`UILabel`，所以在执行整个翻转效果前需要先复制一个当前`UILabel`：

``` swift

let devtalkingLabelCopy = UILabel(frame: self.devtalkingLabel.frame)
devtalkingLabelCopy.alpha = 0
devtalkingLabelCopy.text = self.devtalkingLabel.text
devtalkingLabelCopy.font = self.devtalkingLabel.font
devtalkingLabelCopy.textAlignment = self.devtalkingLabel.textAlignment
devtalkingLabelCopy.textColor = self.devtalkingLabel.textColor
devtalkingLabelCopy.backgroundColor = UIColor.clearColor()

```

这样我们就复制了一个`devtalkingLabel`，这个复制品将作为底部的那一面，而且在一开始它的透明度是零，因为底面是看不到的。我们可以想象一下底面向上翻转的效果，其实就是底面的高度从很小慢慢变大，位置从下慢慢向上移动，然后有一个淡入的效果，所以我们在复制出`devtalkingLabelCopy`后，要调整它的高度和位置，然后添加到父视图中：

``` swift

devtalkingLabelCopy.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.1), CGAffineTransformMakeTranslation(1.0, self.devtalkingLabel.frame.height / 2))
self.view.addSubview(devtalkingLabelCopy)

```

上述代码将`devtalkingLabelCopy`的高度减小到原本的十分之一，位置向下移动半个高度的位置，然后在之前的`animateWithDuration`方法的`animations`闭包中添加如下两行代码：

``` swift

devtalkingLabelCopy.alpha = 1
devtalkingLabelCopy.transform = CGAffineTransformIdentity

```

`CGAffineTransformIdentity`的作用是将`UIView`的`transform`恢复到初始状态，然后将透明度设为1。编译运行代码我们会看到`devtalkingLabel`的高度会慢慢变小，位置慢慢上移，最后淡出，`devtalkingLabelCopy`的高度慢慢变大，位置慢慢上移，最后淡入，整个效果看上去就像一个长方体在向上翻转，达到3D的效果：

![Practice-5][image-5]

## 替换UIView过渡动画
在要实现的动画示例中，背景图做了淡入淡出的图片替换过渡动画，这个动画很简单，我们来看看这段伪代码：

``` swift

UIView.transitionWithView(backgroundImageView, duration: 2, options: .TransitionCrossDissolve, animations: {
    backgroundImageView.image = UIImage(named: "imageName")
}, completion: nil)

```

这个方法在上一篇文章中已经介绍过，我们只需要设置动画选项为`.TransitionCrossDissolve`，在`animations`闭包中给目标`UIImageView`设置要过渡的图片即可。

## 示例动画
至此，示例动画中用到的动画知识点都向大家介绍过了，在这一节我会将示例动画中主要的效果的伪代码贴出来给大家说说。关于左右滑动的手势以及`PageControl`在这里就不在累赘了。

### 数据源
为了方便，我们创建一个`Flight.plist`文件作为数据源：

![Practice-6][image-6]

我们定义一个延迟加载的属性`flight`：

``` swift

lazy var flight: NSArray = {
    let path = NSBundle.mainBundle().pathForResource("Flight", ofType: "plist")
    return NSArray(contentsOfFile: path!)!
}()

```

### 背景图片过渡

``` swift

UIView.transitionWithView(self.backgroundImageView, duration: 2, options: .TransitionCrossDissolve, animations: {
    self.backgroundImageView.image = UIImage(named: flightItem["bg"] as! String)
}, completion: nil)

```

上一节刚介绍过，只是这里图片名称是从数据源中获取的。

### 3D翻转

因为有3D翻转动画效果的`UIView`比较多，而且有`UILabel`也有`UIImageView`，所以我们可以提炼成一个方法，将目标`UIView`和数据源作为参数：

``` swift

func cubeAnimate(targetView: UIView, flightInfo: String) {
    // 判断UIView的具体实现类
    if targetView.isKindOfClass(UILabel) {
        let virtualTargetView = targetView as! UILabel
        // 复制UIView，作为底面
        let viewCopy = UILabel(frame: virtualTargetView.frame)
        viewCopy.alpha = 0
        viewCopy.text = flightInfo
        viewCopy.font = virtualTargetView.font
        viewCopy.textAlignment = virtualTargetView.textAlignment
        viewCopy.textColor = virtualTargetView.textColor
        viewCopy.backgroundColor = UIColor.clearColor()
        // 设置底面UIView的初始位置和高度
        viewCopy.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.1), CGAffineTransformMakeTranslation(1.0, viewCopy.frame.height / 2))
        self.topView.addSubview(viewCopy)
        UIView.animateWithDuration(2, animations: {
            // 执行UIView和UIViewCopy的动画
            virtualTargetView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.1), CGAffineTransformMakeTranslation(1.0, -virtualTargetView.frame.height / 2))
            virtualTargetView.alpha = 0
            viewCopy.alpha = 1
            viewCopy.transform = CGAffineTransformIdentity
        }, completion: { _ in
            // 当动画执行完毕后，将UIViewCopy的信息赋值给UIView，并还原UIView的状态，即与UIViewCopy相同的状态，然后移除UIViewCopy
            virtualTargetView.alpha = 1
            virtualTargetView.text = viewCopy.text
            virtualTargetView.transform = CGAffineTransformIdentity
            viewCopy.removeFromSuperview()
        })
     } else if targetView.isKindOfClass(UIImageView) {
         let virtualTargetView = targetView as! UIImageView
         let viewCopy = UIImageView(frame: virtualTargetView.frame)
         viewCopy.alpha = 0
         viewCopy.image = UIImage(named: flightInfo)
         viewCopy.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.1), CGAffineTransformMakeTranslation(1.0, viewCopy.frame.height / 2))
         self.topView.addSubview(viewCopy)
         UIView.animateWithDuration(2, animations: {
             virtualTargetView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, 0.1), CGAffineTransformMakeTranslation(1.0, -virtualTargetView.frame.height / 2))
             virtualTargetView.alpha = 0
             viewCopy.alpha = 1
             viewCopy.transform = CGAffineTransformIdentity
         }, completion: { _ in
             virtualTargetView.alpha = 1
             virtualTargetView.image = viewCopy.image
             virtualTargetView.transform = CGAffineTransformIdentity
             viewCopy.removeFromSuperview()
         })
     }
}

```

具体有这么几个步骤：

- 判断`UIView`的具体实现类，判断是`UILabel`还是`UIImageView`。
- 复制一份`UIView`，作为底面。
- 设置`UIViewCopy`的初始位置和高度。
- 执行UIView`和`UIViewCopy\`的动画。
- 当动画执行完毕后，将`UIViewCopy`的信息赋值给`UIView`，并还原`UIView`的状态，即与`UIViewCopy`相同的状态，然后移除`UIViewCopy`。

### 小箭头旋转动画
因为航班信息有已降落和即将起飞两种状态，所以小箭头旋转涉及到一个方向问题，我们可以先定义一个枚举类型：

``` swift

enum RotateDirection: Int {
    case Positive = 1
    case Negative = -1
}

```

然后写一个箭头旋转的方法：

``` swift

func rotateAnimate(direction: Int) {
   UIView.animateWithDuration(2, animations: {
       // 判断向上还是向下旋转
       if RotateDirection.Positive.rawValue == direction {
           // 在这个示例中小箭头的初始状态是飞机已降落状态，所以想要箭头从起飞状态旋转到降落状态，只要恢复初始状态即可
           self.landedOrDepatureSmallArrowImageView.transform = CGAffineTransformIdentity
       } else {
           // 向上旋转
           let rotation = CGAffineTransformMakeRotation(CGFloat(RotateDirection.Negative.rawValue) * CGFloat(M_PI_2))
           self.landedOrDepatureSmallArrowImageView.transform = rotation
       }
    }, completion: nil)
}

```

给大家解释一下上述方法的几个步骤：

- 首先判断旋转的方向，通过传入的`direction`参数。
- 如果判断出是降落状态的箭头，也就是向下旋转的箭头，那么我们只需要将`landedOrDepatureSmallArrowImageView`的`transform`属性恢复初始值即可，因为在这个示例中小箭头的初始状态就是飞机降落状态。
- 向上旋转时创建一个`CGAffineTransformMakeRotation`，然后设置正确地方向和角度即可。

>  注：`CGAffineTransformMakeRotation`转换每次都是以初始位置为准，`CGAffineTransformRotation`转换是以每次的旋转位置为准。

### 地点和飞机动画
起飞地、目的地、飞机的动画是一个组合动画，因为这里面存在飞机出现和消失，以及旋转的时机问题，我们来看看这个方法：

``` swift

func placeAndAirplaneAnimate(flightItem: NSDictionary) {
    UIView.animateWithDuration(1, delay: 0, options: [], animations: {
        // 将起飞地向上移动，同时淡出
        self.targetPlace.center.y += 100
        self.targetPlace.alpha = 0
        // 将目的地向下移动，同时淡出
        self.sourcePlace.center.y -= 100
        self.sourcePlace.alpha = 0
        // 将飞机向右移出屏幕
        self.airplaneImageView.center.x += self.view.bounds.width / 1.5
        }, completion: { _ in
            // 根据传入的数据源更改起飞地和目的地
            self.targetPlace.text = flightItem["targetPlace"] as? String
            self.sourcePlace.text = flightItem["sourcePlace"] as? String
            // 将飞机移到屏幕左侧外，这里没有补间动画
            self.airplaneImageView.center.x -= self.view.bounds.width * 1.5
            // 将飞机向上旋转一个角度，这里没有补间动画
            self.airplaneImageView.transform = CGAffineTransformMakeRotation(-3.14/10)
            UIView.animateWithDuration(1.0, animations: {
                // 将起飞地向下移动，也就是恢复到初始位值，同时淡入
                self.targetPlace.center.y -= 100
                self.targetPlace.alpha = 1
                // 将目的地向上移动，也就是恢复到初始位值，同时淡入
                self.sourcePlace.center.y += 100
                self.sourcePlace.alpha = 1
                // 将飞机移动到初始位置
                self.airplaneImageView.center = self.airplaneImageViewOriginalCenter
            })
            UIView.animateWithDuration(0.7, delay: 0.5, options: [], animations: {
                // 将飞机的角度恢复到初始状态
                self.airplaneImageView.transform = CGAffineTransformIdentity
            }, completion: nil)
    })
}

```

刨析一下这个方法：

- 首先是起飞地向上移动同时淡出、目的地向下移动同时淡出、将飞机向右移出屏幕，这些动画属性的改变会产生补间动画。
- 然后当上面这些动画结束后，根据数据源参数更改起飞地和目的地的值，同时将飞机移动屏幕左侧外并向上旋转一个角度，这些属性的改变是不会产生补间动画的，应为它们在`completion`闭包中。
- 最后再使用两个动画方法将起飞地向下移动，也就是恢复到初始位值同时淡入，将目的地向上移动，也就是恢复到初始位值同时淡入，将飞机移动到初始位置，将飞机的角度恢复到初始状态。这里为什么不把恢复飞机角度和恢复位置放在一个动画方法里呢？因为恢复飞机角度需要一个延迟时间，也就是当飞机飞入屏幕一会后再恢复角度，表示一个降落的效果，使动画看起来更加逼真。

还有底部的时间还有地点下地横线都是淡入淡出的动画比较简单，这里就不在累赘了。

## 结束语
再简单地动画效果只要组合的恰当，值设置的考究都可以做出出色的动画效果。这些简单地动画效果也是复杂动画效果的基础。上述动画示例的代码可能写的不够精细，还可以提炼的有层次，不过大家了解了知识点后可以自己实现更考究的代码结构，实现更精致的动画。


[1]:	http://www.devtalking.com/articles/uiview-animation-practice/ "原文链接"
[2]:	http://www.raywenderlich.com/73286/top-5-ios-7-animations

[image-1]:	http://7xpp8a.com1.z0.glb.clouddn.com/UIViewAnimation-Practice-1.gif
[image-2]:	http://7xpp8a.com1.z0.glb.clouddn.com/UIViewAnimation-Practice-1.png
[image-3]:	http://7xpp8a.com1.z0.glb.clouddn.com/UIViewAnimation-Practice-2.png
[image-4]:	http://7xpp8a.com1.z0.glb.clouddn.com/UIViewAnimation-Practice-4.gif
[image-5]:	http://7xpp8a.com1.z0.glb.clouddn.com/UIViewAnimation-Practice-5.gif
[image-6]:	http://7xpp8a.com1.z0.glb.clouddn.com/UIViewAnimation-Practice-6.png