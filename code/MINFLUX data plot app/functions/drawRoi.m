function roi = drawRoi (app, ax)
    switch app.ROIshapeDropDown.Value
        case 'Box'
            roi = drawrectangle(ax, 'Color', app.color_roi, 'StripeColor', 'none', 'LineWidth', 1);
        case 'Oval'
            roi = drawcircle(ax, 'Color', app.color_roi, 'StripeColor', 'none', 'LineWidth', 1);
        case 'Polygon'
            roi = drawpolygon(ax, 'Color', app.color_roi, 'StripeColor', 'none', 'LineWidth', 1);
        case 'Freehand'
            roi = drawfreehand(ax, 'Color', app.color_roi, 'StripeColor', 'none', 'LineWidth', 1);
    end
end