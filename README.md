# ScrollableTextField

## Introduction

When you have long contents, it is more troublesome for UITextFiled to locate the content you want to see. You need to long press and move slowly to the position. 
This view can be easily scrolled to the desired position you want.

## Preview

![img](https://github.com/sunshuyao/ScrollableTextField/blob/master/scroll.gif?raw=true)

## Usage

```
let scrollableTextField = ScrollableTextField(frame: CGRect(x: 50, y: 150, width: 200, height: 50))
self.view.addSubview(scrollableTextField)
// or use masonry/snapkit
let scrollableTextField = ScrollableTextField(frame: .zero)
self.view.addSubview(scrollableTextField)
scrollableTextField.snp.makeConstraints {
  // $0.edges.equalTo...
}
```

## Discuss

ScrollableTextField is kind of UIView, and real UITextField is its subview, which means if you want to add delegate or add target to textFiled, you should visit instance.textField .

```
scrollableTextField.textField.addTarget(self, action: #selector(handleTextField(_:)), for: .editingChanged)
```
