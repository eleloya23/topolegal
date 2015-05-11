include Magick

module Topolegal
  class Ocr

    def process_img(filename)
      img = ImageList.new(filename)
      pixs = refine_img(img.export_pixels, 2, img.columns, img.rows)
      pixs = clean_img(pixs, img.columns, img.rows)

      new_img = Image.new(img.columns,img.rows)
      new_img.import_pixels(0,0, img.columns, img.rows, 'RGB', pixs)
      new_img.write('tmp/result.jpg')

      captcha = Tesseract::Engine.new { |e|
        e.whitelist = [*'A'..'Z', *0..9].join
      }

      captcha.text_for('tmp/result.jpg').gsub('\s', '')
    end

    def refine_img (pixels, chunk_size, cols, rows)
      i = 0
      while i <  rows
        j = 0
        while j < cols

          sum = 0

          for a in i..i+chunk_size-1
            for b in j..j+chunk_size-1
              val = pixels[(b + a * cols) * 3]
              sum += val == nil ? 0 : val
            end
          end

          avg = sum / (chunk_size*chunk_size)
          color = avg > 32768 ? 65535 : 0

          for a in i..i+chunk_size-1
            for b in j..j+chunk_size-1
              pixels[(b + a * cols) * 3] = color
              pixels[(b + a * cols) * 3 + 1] = color
              pixels[(b + a * cols) * 3 + 2] = color
            end
          end

          j+=chunk_size
        end

        i+=chunk_size
      end

      pixels
    end

    def clean_img (pixels, cols, rows)
      pix_map = Array.new(rows * cols, 0)
      pix_no = []

      for i in 0..rows-1
        for j in 0..cols-1
          if pixels[(j + i * cols) * 3] == 0
            pno = 0

            if i - 1 > 0 and j - 1 > 0 and pix_map[(j-1) + (i-1) * cols] > 0 # diag ar i
              pno = pix_map[(j-1) + (i-1) * cols]
            elsif i - 1 > 0 and pix_map[j + (i-1) * cols] > 0 # arriba
              pno = pix_map[j + (i-1) * cols]
            elsif i - 1 > 0 and j + 1 < cols-1 and pix_map[(j+1) + (i-1) * cols] > 0 # diag ar d
              pno = pix_map[(j+1) + (i-1) * cols]
            elsif j - 1 > 0 and pix_map[(j-1) + i * cols] > 0 # izq
              pno = pix_map[(j-1) + i * cols]
            elsif j + 1 < cols-1 and pix_map[(j+1) + i * cols] > 0 # der
              pno = pix_map[(j+1) + i * cols]
            elsif i + 1 < rows-1 and j - 1 > 0 and pix_map[(j-1) + (i+1) * cols] > 0 # diag ab i
              pno = pix_map[(j-1) + (i+1) * cols]
            elsif i + 1 < rows-1 and pix_map[j + (i+1) * cols] > 0 # abajo
              pno = pix_map[j + (i+1) * cols]
            elsif i + 1 < rows-1 and j + 1 < cols-1 and pix_map[(j+1) + (1+1) * cols] > 0 # diag ab d
              pno = pix_map[(j+1) + (i+1) * cols]
            end

            if pno == 0
              pix_no.push(1)
              pno = pix_no.length
            else
              pix_no[pno-1] += 1
            end

            pix_map[j + i * cols] = pno
          end
        end
      end

      for i in 0..pix_no.length-1
        # puts pix_no[i]
        if pix_no[i] < 8
          remove_pixels(pixels, pix_map, i+1, cols, rows)
        end
      end

      pixels
    end

    def remove_pixels(pixels, pixmap, remove_no, cols, rows)
      for i in 0..rows-1
        for j in 0..cols-1
          if pixmap[j + i * cols] == remove_no
            pixels[(j + i * cols) * 3] = 65535
            pixels[(j + i * cols) * 3 + 1] = 65535
            pixels[(j + i * cols) * 3 + 2] = 65535
          end
        end
      end
    end

  end
end
