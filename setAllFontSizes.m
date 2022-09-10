function setAllFontSizes(uiHandle,newFontSize)
    set(findall(uiHandle,'-property','FontSize'),'FontSize',newFontSize)
end